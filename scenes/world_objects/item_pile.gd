extends WorldObject

class_name ItemPile
const self_scene:PackedScene = preload("res://scenes/world_objects/item_pile.tscn")

static func constructor(dat:WorldObjectData) -> ItemPile:
	var obj := self_scene.instantiate()
	obj.data = dat
	obj.type = MyEnums.OBJECT_TYPES.ITEM_PILE
	return obj

func _on_content_changed() -> void:
	var total_content = 0
	for key in content.keys():
		total_content += content[key]
	if total_content <= 0:
		i_died.emit(self)
