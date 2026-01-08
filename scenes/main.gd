extends Node

@onready var world:CanvasLayer = $World
@onready var drag_preview:Control = world.drag_preview
@onready var obj_content_window:CanvasLayer = $ObjectContentWindow
@onready var task_queue_manager:CanvasLayer = $TaskQueue
@onready var task_queue = task_queue_manager.task_queue

func _ready() -> void:
	world.connect("world_map_cell_clicked",_on_world_map_cell_clicked)
	obj_content_window.connect("task_added",_on_task_added)
	
	var new_resource_pile:ResourcePile
	for i in range(1000):
		new_resource_pile = ResourcePile.constructor(load("res://assets/resource_piles/rocks_small.tres"))
		world.place_world_object_at_random(new_resource_pile)
	
	world.add_worker(Vector2i(0,0))

func _process(delta: float) -> void:
	# if there are tasks and there are free workers: assign task to the next worker
	for task:Task in task_queue.get_children():
		if task.completed == true:
			task_queue_manager.remove_task(task)
	if task_queue.get_child_count() > 0 and world.workers.free_workers.get_child_count() > 0 and not task_queue.get_child(-1).being_worked_on:
		var i:int = 0
		while task_queue.get_child(i).being_worked_on:
			i += 1
		var worker:Worker = world.workers.free_workers.get_child(0)
		var task:Task = task_queue.get_child(i)
		worker.queued_movement = world.world_map.plot_course(worker.coordinate,task.object.coordinate)
		worker.current_task = task
		task.being_worked_on = true

func _on_task_added(task:Task) -> void:
	task_queue_manager.add_task(task)

func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if drag_preview.dragged_building != null:
			if world.add_world_object(drag_preview.dragged_building,position):
				drag_preview.dragged_building = null
		else:
			var objects:Array[WorldObject] = world.get_objects_at_location(position)
			if len(objects) > 0:
				obj_content_window.clear_display()
				for object in objects:
					obj_content_window.display_object(object)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		obj_content_window.visible = false
