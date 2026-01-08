extends WorldObject

class_name ResourcePile
const self_scene:PackedScene = preload("res://scenes/world_objects/ressource_pile.tscn")

var total_content = 0

static func constructor(dat:ResourcePileData) -> ResourcePile:
	var obj := self_scene.instantiate()
	obj.data = dat
	obj.add_resource(dat.contained_resource,dat.contained_amount)
	obj.type = MyEnums.OBJECT_TYPES.RESOURCE_PILE
	return obj

func _on_content_changed() -> void:
	total_content = 0
	for key in content.keys():
		total_content += content[key]
		
	if total_content <= 0:
		i_died.emit(self)
