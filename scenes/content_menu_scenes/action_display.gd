extends VBoxContainer

class_name ActionDisplay
const self_scene:PackedScene = preload("res://scenes/content_menu_scenes/action_display.tscn")

signal action_button_pressed

@onready var info_label:Label = $HBoxContainer/MarginContainer/Label
@onready var action_button:Button = $Button
@onready var action_texture:TextureRect = $HBoxContainer/TextureRect

var world_object:WorldObject
var action:ObjectAction

static func constructor(associated_action:ObjectAction,associated_object:WorldObject) -> ActionDisplay:
	var obj := self_scene.instantiate()
	obj.world_object = associated_object
	obj.action = associated_action
	return obj

func _ready() -> void:
	info_label.text = action.info_text
	action_button.text = action.action_text
	action_texture.texture = action.texture
	

func _on_button_button_down() -> void:
	var needed_ressource_amount = 0 #TODO handle stuff needing ressources and adding the extra tasks to collect them
	var task:Task = Task.constructor(world_object,action)
	action_button_pressed.emit(task)
