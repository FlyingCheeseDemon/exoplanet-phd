extends Control

class_name BuildingPreview
const self_scene:PackedScene = preload("res://scenes/build_menu_scenes/building_preview.tscn")

@onready var icon_container:TextureRect = $PreviewContainer/TextureRect
@onready var label_container:Label = $PreviewContainer/Label

var data:BuildingData

static func constructor(dat:BuildingData) -> Building:
	var obj := self_scene.instantiate()
	obj.data = dat
	return obj

func _ready() -> void:
	icon_container.texture = data.texture
	label_container.text = data.name
