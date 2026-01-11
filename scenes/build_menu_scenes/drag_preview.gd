extends Control

var dragged_building:Building = null:
	set = set_dragged_building
	
@onready var building_icon := $BuildingIcon
var world_grid:TileMapLayer

func set_dragged_building(building:Building) -> void:
	dragged_building = building
	_update_visuals()

func _update_visuals() -> void:
	if dragged_building:
		building_icon.texture = dragged_building.data.texture
		building_icon.rotation = PI/3*dragged_building.orientation
		building_icon.position = (dragged_building.data.texture_offset).rotated(PI/3*dragged_building.orientation)
	else:
		building_icon.texture = null

func _process(delta: float) -> void:
	if dragged_building == null:
		return
	var current_position:Vector2i = world_grid.local_to_map(world_grid.to_local(world_grid.get_local_mouse_position()))
	position = world_grid.map_to_local(current_position)
	if Input.is_action_just_pressed("rotate_building"):
		if dragged_building:
			dragged_building.rotate_60()
			_update_visuals()
	if Input.is_action_just_pressed("discard"):
		dragged_building.queue_free()
		dragged_building = null
		_update_visuals()
