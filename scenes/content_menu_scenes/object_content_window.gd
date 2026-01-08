extends CanvasLayer

@onready var pages:TabContainer = $Control/TabContainer

signal task_added

func _process(delta: float) -> void:
	if pages.get_child_count() == 0:
		visible = false
	else:
		visible = true

func clear_display() -> void:
	for child in pages.get_children():
		child.queue_free()

func display_object(world_object:WorldObject) -> void:
	var page := ObjectContentPage.constructor(world_object)
	print(page.name)
	page.connect("task_added",_on_task_added)
	pages.add_child(page)
	pages.set_tab_title(-1,world_object.data.name)
	page.update_display()

func _on_task_added(task:Task) -> void:
	task_added.emit(task)
