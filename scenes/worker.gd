extends Sprite2D

class_name Worker
const self_scene:PackedScene = preload("res://scenes/worker.tscn")
const ACTIONS = preload("res://scripts/actions.gd")
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

signal worker_moved
signal task_started
signal task_ended

@export_group("Initialization")
@export var coordinate:Vector2i

@export_group("Stats")
## tiles/second
@export var movement_speed:float = 1 #in tiles/second
@export var action_speed:float = 0.2 # units/second
@export var inventory_size:int = 10
var inventory:Dictionary # where for each enum key in RESOURCE_DICT there is an associated amount

var current_task:Task:
	set = set_task
var action_delay_ctr:float = 0

static func constructor(location:Vector2i) -> Worker:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	return obj
	
func set_task(new_task:Task) -> void:
	current_task = new_task
	if new_task == null:
		task_ended.emit(self)
	else:
		task_started.emit(self)

var movement_delay_ctr:float = 0
var queued_movement:Array[Vector2i] = []


func _process(delta: float) -> void:
	
	if len(queued_movement) > 0:
		movement_delay_ctr += delta
		if movement_delay_ctr >= 1/movement_speed:
			coordinate = queued_movement.pop_front()
			worker_moved.emit(self)
			movement_delay_ctr = 0
	elif current_task != null:
		action_delay_ctr += delta
		if action_delay_ctr >= 1/action_speed:
			var world = get_node("/root/Main").world
			var finished:bool = action_method_dict[current_task.action.action].call(self,current_task.object,world,coordinate)
			if finished:
				task_ended.emit(self)
				current_task.completed = true
				current_task = null
			action_delay_ctr = 0

##### ACTIONS HERE

var action_method_dict:Dictionary = {
	ACTIONS.ACTIONS.EXTRACT: action_extract,
	ACTIONS.ACTIONS.PICKUP: action_pick_up
}

func action(worker:Worker,object:WorldObject,world:World,location:Vector2i) -> bool:
	# the return value states if the task is finished now
	return true
	
func action_extract(worker:Worker,object:ResourcePile,world:World,location:Vector2i) -> bool:
	if object.current_contained_amount == 0:
		world.remove_resource_pile(location)
		return true
		
	object.current_contained_amount -= 1
	var item_pile_to_pile_on:ItemPile
	if location in world.item_pile_occupancy_dict and world.item_pile_occupancy_dict[location] != null:
		item_pile_to_pile_on = world.item_pile_occupancy_dict[location]
	else:
		item_pile_to_pile_on = ItemPile.constructor(load("res://assets/resources/item_pile.tres"))
		world.add_world_object(item_pile_to_pile_on,location)
	
	var deposited:bool = false
	for key in item_pile_to_pile_on.content.keys():
		if key == object.data.contained_resource:
			item_pile_to_pile_on.content[key] += 1
			deposited = true
			break
	
	if not deposited:
		item_pile_to_pile_on.content[object.data.contained_resource] = 1
		
	print("Extracted 1 " + str(RESOURCE_ENUM.RESOURCE_TYPES.keys()[object.data.contained_resource]) + "!")
	
	if object.current_contained_amount == 0:
		world.remove_resource_pile(location)
		return true
	
	return false

func action_pick_up(worker:Worker,object:WorldObject,world:World,location:Vector2i) -> bool:
	if object == null: # to queue picking up a pile that doesn't yet exist and the moment of task generation
		var objects:Array[WorldObject] = world.get_objects_at_location(location)
		for obj in objects:
			if obj is ItemPile:
				object = obj
				break
		if object == null: # nothing to be picked up here
			return true
				
	for key in object.content.keys():
		if key in worker.inventory.keys():
			worker.inventory[key] += object.content[key]
		else:
			worker.inventory[key] = object.content[key]
		print("Worker picked up " + str(object.content[key]) + " " + str(RESOURCE_ENUM.RESOURCE_TYPES.keys()[key]))
	world.remove_item_pile(location)
	return true
