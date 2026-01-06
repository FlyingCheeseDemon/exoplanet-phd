extends CanvasLayer

signal action_added

@onready var name_label:Label = $Control/MarginContainer/MarginContainer/VBoxContainer/LabelName
@onready var info_label:Label = $Control/MarginContainer/MarginContainer/VBoxContainer/LabelInfo
@onready var action_container:VBoxContainer = $Control/MarginContainer/MarginContainer/VBoxContainer/ActionContainer

func display_object(world_object:WorldObject) -> void:
	name_label.text = world_object.data.name
	info_label.text = world_object.data.info
	for child in action_container.get_children():
		child.queue_free()
	for action in world_object.data.actions:
		var action_display = ActionDisplay.constructor(action,world_object)
		action_container.add_child(action_display)
		action_display.connect("action_button_pressed",_on_action_button_pressed)
	visible = true

func _on_action_button_pressed(task:Task) -> void:
	action_added.emit(task)
