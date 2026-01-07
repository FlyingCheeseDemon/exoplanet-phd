extends WorldObject

class_name ItemPile
const self_scene:PackedScene = preload("res://scenes/world_objects/item_pile.tscn")
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

var content_resources:Array[RESOURCE_ENUM.RESOURCE_TYPES]
var content_resources_amounts:Array[int]

static func constructor(dat:WorldObjectData) -> ItemPile:
	var obj := self_scene.instantiate()
	obj.data = dat
	return obj
