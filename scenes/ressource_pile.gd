extends WorldObject

class_name ResourcePile
const self_scene:PackedScene = preload("res://scenes/ressource_pile.tscn")

static func constructor(dat:ResourcePileData,location:Vector2i) -> ResourcePile:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	return obj
