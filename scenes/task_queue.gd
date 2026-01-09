extends CanvasLayer

@onready var action_queue_display:HBoxContainer = $Control/HBoxContainer
@onready var task_queue:Node = $Tasks

var texture_rect_index:Dictionary = {}

func add_task(task:ComplexTask) -> void:
	task_queue.add_child(task)
	var task_icon = TextureRect.new()
	task_icon.texture = task.action.texture
	task_icon.stretch_mode = TextureRect.STRETCH_KEEP
	action_queue_display.add_child(task_icon)
	texture_rect_index[task] = task_icon

func remove_task(task:ComplexTask) -> void:
	texture_rect_index[task].queue_free()
	task.worker.current_task = null
	task.queue_free()
