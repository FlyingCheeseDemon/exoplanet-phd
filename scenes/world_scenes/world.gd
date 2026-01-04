extends CanvasLayer

@onready var world_map:TileMapLayer = $WorldMap
@onready var camera:Camera2D = $Camera2D
@onready var buildings:Node = $Buildings

func _ready() -> void:
	for building in buildings.get_children():
		update_building_position(building)
		occupancy_dict[building.coordinate] = building

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
	for position in building.data.occupancy:
		var global_coordinate = coordinate + position
		print(world_map.get_cell_source_id(global_coordinate))
		if global_coordinate in occupancy_dict and occupancy_dict[global_coordinate] != null:
			print("Occupied")
			return false
		elif world_map.terrain_index[global_coordinate] != 1:
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

func add_building_occupancy(building:Building) -> void:
	var coordinate := building.coordinate
	for position in building.data.occupancy:
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = building
		
func remove_building_occupancy(building:Building) -> void:
	var coordinate := building.coordinate
	for position in building.data.occupancy:
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = null

func update_building_position(building:Building) -> void:
	var world_position:Vector2 = world_map.map_to_local(building.coordinate)
	building.position = world_position

func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		var new_building = Building.constructor(load("res://assets/buildings/test_small.tres"),Vector2i(0,0))
		add_building(new_building,position)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		remove_building(position)
		
