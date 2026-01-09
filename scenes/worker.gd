extends Sprite2D

class_name Worker
const self_scene:PackedScene = preload("res://scenes/worker.tscn")

signal worker_moved
signal task_started
signal task_ended

signal request_path

@export_group("Initialization")
@export var coordinate:Vector2i

@export_group("Stats")
## tiles/second
@export var movement_speed:float = 1 #in tiles/second
@export var action_speed:float = 0.2 # units/second
@export var inventory_size:int = 10
var inventory:Dictionary # where for each enum key in RESOURCE_DICT there is an associated amount

var current_task:ComplexTask:
	set = set_task
var action_delay_ctr:float = 0

static func constructor(location:Vector2i) -> Worker:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	return obj
	
func set_task(new_task:ComplexTask) -> void:
	current_task = new_task
	if new_task == null:
		queued_movement = []
	else:
		task_started.emit(self)
		task_index = 0
		print(len(current_task.subtasks))
		get_next_target()

var movement_delay_ctr:float = 0
var queued_movement:Array[Vector2i] = []
var current_target:Vector2i

var task_index:int

@onready var world = get_node("/root/Main").world

func _process(delta: float) -> void:
	
	if len(queued_movement) > 0:
		movement_delay_ctr += delta
		if movement_delay_ctr >= 1/movement_speed:
			coordinate = queued_movement.pop_front()
			worker_moved.emit(self)
			movement_delay_ctr = 0
	elif current_task != null:
		if current_target == coordinate:
			action_delay_ctr += delta
			if action_delay_ctr >= 1/action_speed:
				
				var finished:bool = action_method_dict[current_task.subtasks[task_index]].call({})
				print(finished)
				print(task_index)
				
				if finished:
					task_index += 1
					if task_index >= len(current_task.subtasks):
						task_ended.emit(self)
					else:
						get_next_target()
				action_delay_ctr = 0
		else:
			get_next_target()

func get_next_target() -> void:
	match current_task.subtasks[task_index]:
		MyEnums.ACTIONS.EXTRACT: current_target = current_task.object.coordinate
		MyEnums.ACTIONS.PICKUP: current_target = current_task.object.coordinate
		MyEnums.ACTIONS.NONE: current_target = coordinate
		MyEnums.ACTIONS.DROPOFF: current_target = world.get_closest_building_x(coordinate,BuildingData.BUILDING_TYPE.STORAGE)
	
	if current_target != coordinate:
		request_path.emit(self,current_target)

func check_inventory_for_stuff(stuff:Dictionary) -> bool:
	for key in stuff:
		if not key in inventory.keys():
			return false
		if inventory[key] < stuff[key]:
			return false
	return true

##### ACTIONS HERE

var action_method_dict:Dictionary = {
	MyEnums.ACTIONS.EXTRACT: action_extract,
	MyEnums.ACTIONS.PICKUP: action_pick_up,
	MyEnums.ACTIONS.NONE: action_,
	MyEnums.ACTIONS.DROPOFF: action_drop_off
}

func action_(_shopping_list:Dictionary) -> bool:
	# the return value states if the task is finished now
	return true

func action_drop_off(shopping_list:Dictionary) -> bool:
	var action_type:MyEnums.OBJECT_TYPES = MyEnums.OBJECT_TYPES.BUILDING
	if not coordinate in world.type_occupancy_dict_dict[action_type]:
		return true
	var object:Building = world.type_occupancy_dict_dict[action_type][coordinate]

	for key in shopping_list:
		if inventory[key] > shopping_list[key]:
			object.add_resource(key,shopping_list[key])
			inventory[key] -= shopping_list[key]
		else:
			object.add_resource(key,inventory[key])
			inventory[key] = 0
	return object.check_content_for_stuff(shopping_list)

func action_extract(_shopping_list:Dictionary) -> bool:
	# the shopping list is not used here
	var action_type:MyEnums.OBJECT_TYPES = MyEnums.OBJECT_TYPES.RESOURCE_PILE
	if not coordinate in world.type_occupancy_dict_dict[action_type]:
		return true
	var object:ResourcePile = world.type_occupancy_dict_dict[action_type][coordinate]
	
	var item_pile_to_pile_on:ItemPile
	if coordinate in world.type_occupancy_dict_dict[MyEnums.OBJECT_TYPES.ITEM_PILE] and world.type_occupancy_dict_dict[MyEnums.OBJECT_TYPES.ITEM_PILE][coordinate] != null:
		item_pile_to_pile_on = world.type_occupancy_dict_dict[MyEnums.OBJECT_TYPES.ITEM_PILE][coordinate]
	else:
		item_pile_to_pile_on = ItemPile.constructor()
		world.add_world_object(item_pile_to_pile_on,coordinate)
	
	item_pile_to_pile_on.add_resource(object.content.keys()[0],object.remove_resource(object.content.keys()[0],1))

	print("Extracted 1 " + str(MyEnums.RESOURCE_TYPES.keys()[object.data.contained_resource]) + "!")
	
	return object.total_content == 0

func action_pick_up(shopping_list:Dictionary) -> bool:
	var action_type:MyEnums.OBJECT_TYPES = MyEnums.OBJECT_TYPES.ITEM_PILE
	if not coordinate in world.type_occupancy_dict_dict[action_type]:
		return false
	var object:ItemPile = world.type_occupancy_dict_dict[action_type][coordinate]
	
	if len(shopping_list.keys()) == 0:
		shopping_list = object.content # pick it all up
	
	for key in shopping_list:
		if key in object.content:
			if not key in inventory.keys():
				inventory[key] = 0
			var amount:int = object.remove_resource(key,shopping_list[key])
			inventory[key] += amount
			print("Worker picked up " + str(amount) + " " + str(MyEnums.RESOURCE_TYPES.keys()[key]))
	
	return check_inventory_for_stuff(shopping_list)
