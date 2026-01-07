extends WorldObject

class_name ItemPile
const self_scene:PackedScene = preload("res://scenes/world_objects/item_pile.tscn")
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

var content:Dictionary # where for each enum key in RESOURCE_ENUM.RESOURCE_TYPES there is an associated amount

static func constructor(dat:WorldObjectData) -> ItemPile:
	var obj := self_scene.instantiate()
	obj.data = dat
	return obj
