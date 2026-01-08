extends Sprite2D

class_name WorldObject

@export var coordinate:Vector2i
@export var data:WorldObjectData

var type:MyEnums.OBJECT_TYPES

var modulated:bool = false
var modulation_color:Color = Color()

var orientation:int = 0
var content:Dictionary

signal i_died

func _ready() -> void:
	texture = data.texture
	if modulated:
		modulate = modulation_color
	offset = data.texture_offset

func rotate_60() -> void:
	orientation = (orientation + 1) % 6
	
func add_resource(res:MyEnums.RESOURCE_TYPES,amount:int) -> int:
	if res in content.keys():
		content[res] += amount
	else:
		content[res] = amount
	_on_content_changed()
	return amount
	
func remove_resource(res:MyEnums.RESOURCE_TYPES,amount:int) -> int:
	if res not in content.keys():
		return 0
	if amount == -1:
		amount = content[res]
	if  content[res] < amount:
		var temp:int = content[res]
		content[res] = 0
		_on_content_changed()
		return temp
	else:
		content[res] -= amount
		_on_content_changed()
		return amount
	
func _on_content_changed() -> void:
	pass
	
func remove_self() -> void:
	i_died.emit(self)
