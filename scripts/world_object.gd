extends Sprite2D

class_name WorldObject

@export var coordinate:Vector2i
@export var data:WorldObjectData

var modulated:bool = false
var modulation_color:Color = Color()

var orientation:int = 0

func _ready() -> void:
	texture = data.texture
	if modulated:
		modulate = modulation_color
	offset = data.texture_offset

func rotate_60() -> void:
	orientation = (orientation + 1) % 6
