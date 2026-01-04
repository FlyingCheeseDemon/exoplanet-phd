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

func _ready() -> void:
	available_buildings.append(load("res://assets/buildings/test_small.tres"))
	available_buildings.append(load("res://assets/buildings/test_medium.tres"))
	update_available_buildings() 
