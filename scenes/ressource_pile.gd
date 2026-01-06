extends WorldObject

class_name ResourcePile
const self_scene:PackedScene = preload("res://scenes/ressource_pile.tscn")

var current_contained_amount

static func constructor(dat:ResourcePileData,location:Vector2i) -> ResourcePile:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	obj.current_contained_amount = dat.contained_amount
	return obj
