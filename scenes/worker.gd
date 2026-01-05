extends Sprite2D

class_name Worker
const self_scene:PackedScene = preload("res://scenes/worker.tscn")

signal worker_moved

@export_group("Initialization")
@export var coordinate:Vector2i

@export_group("Stats")
## tiles/second
@export var movement_speed:float = 1 #in tiles/second
@export var gathering_speed:float = 0.2 # units/second
@export var inventory_size:int = 10

var movement_delay_ctr:float = 0
var queued_movement:Array[Vector2i] = []


static func constructor(location:Vector2i) -> Worker:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	return obj
	
func _process(delta: float) -> void:
	if len(queued_movement) > 0:
		movement_delay_ctr += delta
		if movement_delay_ctr >= 1/movement_speed:
			coordinate = queued_movement.pop_front()
			worker_moved.emit(self)
			movement_delay_ctr = 0
