extends CanvasLayer

@onready var pages:TabContainer = $Control/TabContainer

signal task_added

func _process(delta: float) -> void:
	if pages.get_child_count() == 0:
		visible = false

func clear_display() -> void:
	for child in pages.get_children():
		child.queue_free()

func display_object(world_object:WorldObject) -> void:
	var page := ObjectContentPage.constructor(world_object)
	pages.add_child(page)
	page.name = world_object.data.name
	page.connect("task_added",_on_task_added)
	page.update_display()
	visible = true

func _on_task_added(task:Task) -> void:
	task_added.emit(task)
