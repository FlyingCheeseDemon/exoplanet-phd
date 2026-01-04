extends Sprite2D

class_name Building
const self_scene:PackedScene = preload("res://scenes/building.tscn")

@export var coordinate:Vector2i
@export var data:Building_data

static func constructor(dat:Building_data,location:Vector2i) -> Building:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	return obj

func _ready() -> void:
	texture = data.texture
	offset = data.texture_offset
