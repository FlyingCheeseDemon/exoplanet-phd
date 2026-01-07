extends CanvasLayer

signal task_added

@onready var name_label:Label = $Control/MarginContainer/MarginContainer/VBoxContainer/LabelName
@onready var info_label:Label = $Control/MarginContainer/MarginContainer/VBoxContainer/LabelInfo
@onready var action_container:VBoxContainer = $Control/MarginContainer/MarginContainer/VBoxContainer/ActionContainer
var displayed_world_object:WorldObject

func _process(delta: float) -> void:
	if displayed_world_object == null:
		visible = false

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
