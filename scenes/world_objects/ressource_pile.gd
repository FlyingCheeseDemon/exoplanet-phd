extends WorldObject

class_name ResourcePile
const self_scene:PackedScene = preload("res://scenes/world_objects/ressource_pile.tscn")
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

var current_contained_amount
var contained_resource_name

static func constructor(dat:ResourcePileData) -> ResourcePile:
	var obj := self_scene.instantiate()
	obj.data = dat
	obj.current_contained_amount = dat.contained_amount
	obj.contained_resource_name = RESOURCE_ENUM.RESOURCE_TYPES.keys()[dat.contained_resource].to_pascal_case()
	return obj
