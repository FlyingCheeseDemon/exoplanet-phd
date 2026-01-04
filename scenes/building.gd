extends Sprite2D

class_name Building
const self_scene:PackedScene = preload("res://scenes/building.tscn")

@export var coordinate:Vector2i
@export var data:BuildingData

var orientation:int = 0

static func constructor(dat:BuildingData,location:Vector2i) -> Building:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	return obj

func _ready() -> void:
	texture = data.texture
	offset = data.texture_offset
