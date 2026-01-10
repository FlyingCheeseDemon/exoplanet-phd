extends CanvasLayer

class_name World

@onready var world_map:TileMapLayer = $WorldMap
@onready var visual_world_map:Node2D = $VisualMap
@onready var camera:Camera2D = $Camera2D
@onready var buildings:Node = $Buildings
@onready var resource_piles:Node = $ResourcePiles
@onready var item_piles:Node = $ItemPiles
@onready var workers:Node = $Workers
@onready var drag_preview:Control = $DragPreview

signal world_map_cell_clicked

@export var randomize_colors:bool = true
@export var water_color:Color
@export var land_color:Color
var color_tag_array:Array[Color]

func _ready() -> void:
	for building in buildings.get_children():
		update_world_object_position(building)
		building_occupancy_dict[building.coordinate] = building
	for resource_pile in resource_piles.get_children():
		update_world_object_position(resource_pile)
		resource_pile_occupancy_dict[resource_pile.coordinate] = resource_pile
	for worker in workers.get_children():
		if not worker is Worker:
			continue
		_on_worker_moved(worker)
		worker.connect("worker_moved",_on_worker_moved)
	
	if randomize_colors:
		randomize_world_colors()
	recolor_world(water_color,land_color)
	color_tag_array = [Color(),water_color,land_color]
	visual_world_map.after_world_map_update(world_map)
	

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

var building_occupancy_dict:Dictionary = {} # used as a hashed list for all occupied coordinates
var resource_pile_occupancy_dict:Dictionary = {} # used as a hashed list for all occupied coordinates
var item_pile_occupancy_dict:Dictionary = {}

var type_occupancy_dict_dict:Dictionary = {
	MyEnums.OBJECT_TYPES.BUILDING: building_occupancy_dict,
	MyEnums.OBJECT_TYPES.RESOURCE_PILE: resource_pile_occupancy_dict,
	MyEnums.OBJECT_TYPES.ITEM_PILE: item_pile_occupancy_dict
}

@onready var type_root_node_dict:Dictionary = {
	MyEnums.OBJECT_TYPES.BUILDING: buildings,
	MyEnums.OBJECT_TYPES.RESOURCE_PILE: resource_piles,
	MyEnums.OBJECT_TYPES.ITEM_PILE: item_piles
}

func place_world_object_at_random(world_object:WorldObject):
	var ran:int = world_map.render_range
	var x = randi_range(-ran,ran)
	var y = randi_range(-ran,ran)
	while not add_world_object(world_object,Vector2i(x,y)):
		x = randi_range(-ran,ran)
		y = randi_range(-ran,ran)

func check_placement_world_object(world_object:WorldObject, coordinate:Vector2i) -> bool:
	# check if object can be placed there
	var occupancy_dict:Dictionary = type_occupancy_dict_dict[world_object.type]
		
	for position in world_object.data.occupancy: # vectors in godot are value types.
		# rotate position
		for i in range(world_object.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		if world_map.get_cell_tile_data(global_coordinate) == null:
			return false
		if global_coordinate in occupancy_dict and occupancy_dict[global_coordinate] != null:
			#print("Occupied")
			return false
		# bitwise operation to check if the current tile is allowed to be built on
		elif not (1 << (world_map.get_cell_tile_data(global_coordinate).terrain_set) & world_object.data.build_restriction):
			return false
	return true

func add_world_object(world_object:WorldObject, coordinate:Vector2i) -> bool:
	if not check_placement_world_object(world_object,coordinate):
		return false
	# if so update the coordinate of the building
	world_object.coordinate = coordinate
	add_world_object_occupancy(world_object)
	update_world_object_position(world_object)
	var parent_node:Node = type_root_node_dict[world_object.type]
	if world_object is ResourcePile:
		if world_object.data.color_tag != 0:
			world_object.modulation_color = color_tag_array[world_object.data.color_tag]
			world_object.modulated = true
	
	world_object.connect("i_died",remove_world_object)
	parent_node.add_child(world_object)
	#print("Object placed: " + world_object.data.name)
	return true

func remove_world_object(world_object:WorldObject) -> void:
	if world_object is Building:
		remove_building(world_object.coordinate)
	elif world_object is ResourcePile:
		remove_resource_pile(world_object.coordinate)
	elif world_object is ItemPile:
		remove_item_pile(world_object.coordinate)
		
func remove_building(coordinate:Vector2i) -> bool:
	if not coordinate in building_occupancy_dict or building_occupancy_dict[coordinate] == null:
		print("no building to remove")
		return false
	
	var building_to_remove:Building = building_occupancy_dict[coordinate]
	remove_world_object_occupancy(building_to_remove)
	building_to_remove.queue_free()
	return true
	
func remove_resource_pile(coordinate:Vector2i) -> bool:
	if not coordinate in resource_pile_occupancy_dict or resource_pile_occupancy_dict[coordinate] == null:
		print("no resource pile to remove")
		return false
	
	var pile_to_remove:ResourcePile = resource_pile_occupancy_dict[coordinate]
	remove_world_object_occupancy(pile_to_remove)
	pile_to_remove.queue_free()
	return true
	
func remove_item_pile(coordinate:Vector2i) -> bool:
	if not coordinate in item_pile_occupancy_dict or item_pile_occupancy_dict[coordinate] == null:
		print("no item pile to remove")
		return false
	
	var pile_to_remove:ItemPile = item_pile_occupancy_dict[coordinate]
	remove_world_object_occupancy(pile_to_remove)
	pile_to_remove.queue_free()
	return true

func get_objects_at_location(position:Vector2i) -> Array[WorldObject]:
	var objects:Array[WorldObject] = []
	for key in type_occupancy_dict_dict:
		var current_dict = type_occupancy_dict_dict[key]
		if position in current_dict and current_dict[position] != null:
			objects.append(current_dict[position])
	return objects

func randomize_world_colors() -> void:
	land_color = Color.from_hsv(randf(),randf_range(0.3,0.8),randf_range(0.7,1))
	water_color = Color.from_hsv(randf(),randf_range(0.1,land_color.s),randf_range(land_color.v,1))

func recolor_world(w_color:Color,l_color:Color) -> void:
	visual_world_map.material.set_shader_parameter("water_color",w_color);
	visual_world_map.material.set_shader_parameter("land_color",l_color);

func add_world_object_occupancy(world_object:WorldObject) -> void:
	var occupancy_dict:Dictionary = type_occupancy_dict_dict[world_object.type]
		
	var coordinate := world_object.coordinate
	for position in world_object.data.occupancy:
		for i in range(world_object.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = world_object
		
func remove_world_object_occupancy(world_object:WorldObject) -> void:
	var occupancy_dict:Dictionary = type_occupancy_dict_dict[world_object.type]
		
	var coordinate := world_object.coordinate
	for position in world_object.data.occupancy:
		for i in range(world_object.orientation):
			position = Vector2i(-position[1],position[0]+position[1]) # hexagon grid rotation 60°
		var global_coordinate = coordinate + position
		occupancy_dict[global_coordinate] = null

func update_world_object_position(world_object:WorldObject) -> void:
	var world_position:Vector2 = world_map.map_to_local(world_object.coordinate)
	world_object.position = world_position
	world_object.rotation = PI/3*world_object.orientation
	
func _on_worker_moved(worker:Worker) -> void:
	var world_position:Vector2 = world_map.map_to_local(worker.coordinate)
	worker.position = world_position
	
func add_worker(position:Vector2i) -> Worker:
	var new_worker = Worker.constructor(position)
	workers.add_child(new_worker)
	new_worker.connect("worker_moved",_on_worker_moved)
	new_worker.connect("task_started",workers._on_task_started)
	new_worker.connect("task_ended",workers._on_task_ended)
	new_worker.task_ended.emit(new_worker)
	_on_worker_moved(new_worker)
	return new_worker

func get_closest_building_x(position:Vector2i,identifyer:BuildingData.BUILDING_TYPE) -> Vector2i:
	var closest:Building = null
	var smallest_distance:int = 99999
	for building in buildings.get_children():
		if building.data.type != identifyer:
			continue
		var distance:int = len(world_map.plot_course(position,building.coordinate))
		if distance < smallest_distance:
			smallest_distance = distance
			closest = building
	if closest == null:
		return position
	else:
		return closest.coordinate

func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	emit_signal("world_map_cell_clicked", event, position)
