extends MarginContainer

class_name ObjectContentPage
const self_scene:PackedScene = preload("res://scenes/content_menu_scenes/object_content_window_page.tscn")

@onready var name_label:Label = $MarginContainer/VBoxContainer/LabelName
@onready var info_label:Label = $MarginContainer/VBoxContainer/LabelInfo
@onready var action_container:VBoxContainer = $MarginContainer/VBoxContainer/ActionContainer
var displayed_world_object:WorldObject
var content:Dictionary # where for each enum key in RESOURCE_ENUM.RESOURCE_TYPES there is an associated amount

static func constructor(world_object:WorldObject) -> ObjectContentPage:
	var obj := self_scene.instantiate()
	obj.displayed_world_object = world_object
	return obj

signal task_added

func _process(delta: float) -> void:
	if displayed_world_object == null:
		self.queue_free()

func display_object(world_object:WorldObject) -> void:
	displayed_world_object = world_object
	update_display()
	
func update_display() -> void:
	name_label.text = displayed_world_object.data.name
	info_label.text = displayed_world_object.data.info
	for child in action_container.get_children():
		child.queue_free()
	for action in displayed_world_object.data.actions:
		var action_display = ActionDisplay.constructor(action,displayed_world_object)
		action_container.add_child(action_display)
		action_display.connect("action_button_pressed",_on_action_button_pressed)
	visible = true

func _on_action_button_pressed(task:Task) -> void:
	task_added.emit(task)
