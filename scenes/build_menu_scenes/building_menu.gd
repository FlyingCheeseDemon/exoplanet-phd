extends CanvasLayer

@onready var build_menu:Control = $BuildMenu
@onready var build_tab_container:TabContainer = $BuildMenu/BuildTabContainer

var available_buildings:Array[BuildingData] = []

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_menu"):
		build_menu.visible = not build_menu.visible

func update_available_buildings() -> void:
	# clear the entire thing
	for item_list in build_tab_container.get_children():
		for item in item_list.get_children():
			item.queue_free()
	
	# put them all back in
	for building in available_buildings:
		var display_element := BuildingPreview.constructor(building)
		build_tab_container.get_child(0).add_child(display_element)
		display_element.connect("gui_input",_on_building_selected_from_bar.bind(display_element.data))

func _on_building_selected_from_bar(event:InputEvent,building_data:BuildingData) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_node("/root/Main").drag_preview.dragged_building == null:
				var building := Building.constructor(building_data)
				get_node("/root/Main").drag_preview.dragged_building = building

func _ready() -> void:
	available_buildings.append(load("res://assets/buildings/test_small.tres"))
	available_buildings.append(load("res://assets/buildings/test_medium.tres"))
	update_available_buildings() 
