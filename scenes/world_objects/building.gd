extends WorldObject

class_name Building
const self_scene:PackedScene = preload("res://scenes/world_objects/building.tscn")

static func constructor(dat:BuildingData,location:Vector2i) -> Building:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	return obj
