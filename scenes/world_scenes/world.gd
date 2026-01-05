extends CanvasLayer

@onready var world_map:TileMapLayer = $WorldMap
@onready var camera:Camera2D = $Camera2D
@onready var buildings:Node = $Buildings
@onready var workers:Node = $Workers

const HEX_DIRECTIONS:Array[Vector2i] = [Vector2i(0,1),Vector2i(0,-1),Vector2i(1,0),Vector2i(-1,0),Vector2i(1,-1),Vector2i(-1,1)]

signal world_map_cell_clicked

func _ready() -> void:
	for building in buildings.get_children():
		update_building_position(building)
		occupancy_dict[building.coordinate] = building
	for worker in workers.get_children():
		_on_worker_moved(worker)
		worker.connect("worker_moved",_on_worker_moved)
	
	var land_color:Color = Color.from_hsv(randf(),randf_range(0.3,0.8),randf_range(0.7,1))
	var water_color:Color = Color.from_hsv(randf(),randf_range(0.1,land_color.s),randf_range(land_color.v,1))
	recolor_world(water_color,land_color)

var pan_speed:float = 10

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_plus"):
		if camera.zoom[1] < 1:
			camera.zoom += Vector2(0.1,0.1)
	elif Input.is_action_just_pressed("zoom_minus"):
		if camera.zoom[0] > 0.1:
			camera.zoom -= Vector2(0.1,0.1)
	
	if Input.is_action_pressed("pan_left"):
		camera.position[0] -= pan_speed/camera.zoom[0]
	elif Input.is_action_pressed("pan_right"):
		camera.position[0] += pan_speed/camera.zoom[0]
		
	if Input.is_action_pressed("pan_up"):
		camera.position[1] -= pan_speed/camera.zoom[0]
	elif Input.is_action_pressed("pan_down"):
		camera.position[1] += pan_speed/camera.zoom[0]

var occupancy_dict:Dictionary = {} # used as a hashed list for all occupied coordinates

func check_place_building(building:Building, coordinate:Vector2i) -> bool:
	# check if building can be placed there
	for position in building.data.occupancy: # vectors in godot are value types.
		# rotate position
		for i in range(building.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		if global_coordinate in occupancy_dict and occupancy_dict[global_coordinate] != null:
			print("Occupied")
			return false
		elif world_map.get_cell_tile_data(global_coordinate).terrain_set != 0:
			print("Invalid Terrain")
			return false
	return true

func add_building(building:Building, coordinate:Vector2i) -> bool:
	if not check_place_building(building,coordinate):
		print("Failed to place building")
		return false
	# if so update the coordinate of the building
	building.coordinate = coordinate
	add_building_occupancy(building)
	update_building_position(building)
	buildings.add_child(building)
	print("Building placed")
	return true

func remove_building(coordinate:Vector2i) -> bool:
	if not coordinate in occupancy_dict or occupancy_dict[coordinate] == null:
		print("no building to remove")
		return false
	
	var building_to_remove:Building = occupancy_dict[coordinate]
	remove_building_occupancy(building_to_remove)
	building_to_remove.queue_free()
	
	return true

func recolor_world(water_color:Color,terrain_color:Color) -> void:
	var tiles_colored:Array[bool] = [false,false,false]
	for i in range(-100,100):
		for j in range(-100,100):
			if world_map.get_cell_tile_data(Vector2i(i,j)).terrain_set == 1:
				world_map.get_cell_tile_data(Vector2i(i,j)).modulate = water_color
			else:
				world_map.get_cell_tile_data(Vector2i(i,j)).modulate = terrain_color
				
			tiles_colored[world_map.get_cell_tile_data(Vector2i(i,j)).terrain_set] = true
			if tiles_colored[0] and tiles_colored[1] and tiles_colored[2]:
				return

func add_building_occupancy(building:Building) -> void:
	var coordinate := building.coordinate
	for position in building.data.occupancy:
		for i in range(building.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = building
		
func remove_building_occupancy(building:Building) -> void:
	var coordinate := building.coordinate
	for position in building.data.occupancy:
		for i in range(building.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = null

func update_building_position(building:Building) -> void:
	var world_position:Vector2 = world_map.map_to_local(building.coordinate)
	building.position = world_position
	building.rotation = PI/3*building.orientation
	
func _on_worker_moved(worker:Worker) -> void:
	var world_position:Vector2 = world_map.map_to_local(worker.coordinate)
	worker.position = world_position
	
func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	emit_signal("world_map_cell_clicked", event, position)

func plot_course(start:Vector2i,end:Vector2i) -> Array[Vector2i]:
	# floodfill
	if start == end:
		return []
	
	var frontier_queue:Array[Vector2i] = [end]
	var next_tile_to_goal:Dictionary = {}
	
	while not start in next_tile_to_goal.keys():
		if len(frontier_queue) == 0: # target unreachable
			return []
		var current_position = frontier_queue.pop_front()
		for direction in HEX_DIRECTIONS:
			var next_position:Vector2i = current_position + direction
			if world_map.get_cell_tile_data(next_position).terrain_set != 0:
				continue # impassable
			if next_position in next_tile_to_goal.keys():
				continue # already visited
			frontier_queue.append(next_position)
			next_tile_to_goal[next_position] = current_position
		
	var course:Array[Vector2i] = [start]
		
	while course[-1] != end:
		course.append(next_tile_to_goal[course[-1]])
	
	course.pop_front() # worker is already at this position and doesn't need to move there
	return course
