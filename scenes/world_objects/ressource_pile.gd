extends WorldObject

class_name ResourcePile
const self_scene:PackedScene = preload("res://scenes/world_objects/ressource_pile.tscn")

var current_contained_amount

static func constructor(dat:ResourcePileData) -> ResourcePile:
	var obj := self_scene.instantiate()
	obj.data = dat
	obj.current_contained_amount = dat.contained_amount
	return obj
