extends WorldObject

class_name Building
const self_scene = preload("res://scenes/building.tscn")

static func constructor(dat:BuildingData,location:Vector2i) -> Building:
	var obj := self_scene.instantiate()
	obj.coordinate = location
	obj.data = dat
	return obj
