extends Node

@onready var world:CanvasLayer = $World
@onready var drag_preview:Control = get_node("/root/Main/World/DragPreview")

func _ready() -> void:
	world.connect("world_map_cell_clicked",_on_world_map_cell_clicked)
	pass

func _process(delta: float) -> void:
	pass

func _on_world_map_cell_clicked(event:InputEventMouseButton,position:Vector2i) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if drag_preview.dragged_building != null:
			if world.add_building(drag_preview.dragged_building,position):
				drag_preview.dragged_building = null
		else:
			var our_worker:Worker = world.workers.get_child(0)
			var path:Array[Vector2i] = world.plot_course(our_worker.coordinate,position)
			our_worker.queued_movement = path
			print(world.workers.get_child(0).queued_movement)
