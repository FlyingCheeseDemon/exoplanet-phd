extends Control

var dragged_building:Building = null:
	set = set_dragged_building
	
@onready var building_icon := $BuildingIcon

func set_dragged_building(building:Building) -> void:
	dragged_building = building
	_update_visuals()

func _update_visuals() -> void:
	if dragged_building:
		building_icon.texture = dragged_building.data.texture
		building_icon.rotation = PI/2*dragged_building.orientation
		building_icon.position = dragged_building.data.texture_offset
	else:
		building_icon.texture = null

func _process(delta: float) -> void:
	position = get_global_mouse_position()
	if Input.is_action_just_pressed("rotate_building"):
		if dragged_building:
			#dragged_building.rotate()
			_update_visuals()
