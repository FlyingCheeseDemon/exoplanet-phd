extends WorldObject

class_name Building
const self_scene:PackedScene = preload("res://scenes/world_objects/building.tscn")

var content:Dictionary # where for each enum key in RESOURCE_ENUM.RESOURCE_TYPES there is an associated amount

static func constructor(dat:BuildingData) -> Building:
	var obj := self_scene.instantiate()
	obj.data = dat
	return obj
