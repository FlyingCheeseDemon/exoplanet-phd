extends Node

@onready var world:CanvasLayer = $World
@onready var drag_preview:Control = world.drag_preview
@onready var obj_content_window:CanvasLayer = $ObjectContentWindow
@onready var action_queue:Node = $ActionQueue

func _ready() -> void:
	world.connect("world_map_cell_clicked",_on_world_map_cell_clicked)
	obj_content_window.connect("action_added",_on_action_added)
	
	var new_resource_pile:ResourcePile
	for i in range(1000):
		new_resource_pile = ResourcePile.constructor(load("res://assets/resource_piles/rocks_small.tres"),Vector2i(0,0))
		world.place_world_object_at_random(new_resource_pile)

func _process(delta: float) -> void:
	pass

func _on_action_added(task:Task) -> void:
	action_queue.add_child(task)
	print(action_queue.get_child_count())

func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if drag_preview.dragged_building != null:
			if world.add_world_object(drag_preview.dragged_building,position):
				drag_preview.dragged_building = null
		else:
			var objects:Array[WorldObject] = world.get_objects_at_location(position)
			if len(objects) > 0:
				obj_content_window.display_object(objects[0])
			#var our_worker:Worker = world.workers.get_child(0)'
			#var path:Array[Vector2i] = world.plot_course(our_worker.coordinate,position)
			#our_worker.queued_movement = path
			#print(world.workers.get_child(0).queued_movement)'
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		#print(world.world_map.hex_len(position))
		obj_content_window.visible = false
