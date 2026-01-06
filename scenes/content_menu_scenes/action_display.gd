extends VBoxContainer

class_name ActionDisplay
const self_scene:PackedScene = preload("res://scenes/content_menu_scenes/action_display.tscn")

signal action_button_pressed

@onready var info_label:Label = $Label
@onready var action_button:Button = $Button

var info_text:String
var button_text:String
var world_object:WorldObject
var action:ObjectAction

static func constructor(associated_action:ObjectAction,associated_object:WorldObject) -> ActionDisplay:
	var obj := self_scene.instantiate()
	obj.info_text = associated_action.info_text
	obj.button_text = associated_action.action_text
	obj.world_object = associated_object
	obj.action = associated_action
	return obj

func _ready() -> void:
	info_label.text = info_text
	action_button.text = button_text

func _on_button_button_down() -> void:
	var task:Task = Task.constructor(world_object,action)
	action_button_pressed.emit(task)
