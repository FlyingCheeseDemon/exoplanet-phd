extends Sprite2D

class_name Worker
const self_scene:PackedScene = preload("res://scenes/worker.tscn")
const ACTIONS = preload("res://scripts/actions.gd")

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
		print("Task ended")
		task_ended.emit(self)
	else:
		print("Task started")
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
	ACTIONS.ACTIONS.EXTRACT: action_extract
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
	for i in range(len(item_pile_to_pile_on.content_resources)):
		if item_pile_to_pile_on.content_resources[i] == object.data.contained_resource:
			item_pile_to_pile_on.content_resources_amounts[i] += 1
			deposited = true
			break
	
	if not deposited:
		item_pile_to_pile_on.content_resources.append(object.data.contained_resource)
		item_pile_to_pile_on.content_resources_amounts.append(1)
		
	print("Extracted!")
	
	if object.current_contained_amount == 0:
		world.remove_resource_pile(location)
		return true
	
	return false
