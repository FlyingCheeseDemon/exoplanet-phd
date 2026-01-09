extends VBoxContainer

class_name ActionDisplay
const self_scene:PackedScene = preload("res://scenes/content_menu_scenes/action_display.tscn")

signal action_button_pressed

@onready var info_label:Label = $HBoxContainer/MarginContainer/Label
@onready var action_button:Button = $Button
@onready var action_texture:TextureRect = $HBoxContainer/TextureRect

var world_object:WorldObject
var action:ObjectAction

static func constructor(associated_action:ObjectAction,associated_object:WorldObject) -> ActionDisplay:
	var obj := self_scene.instantiate()
	obj.world_object = associated_object
	obj.action = associated_action
	return obj

func _ready() -> void:
	info_label.text = _format_action_text()
	action_button.text = action.action_text
	action_button.visible = action_button.text != ""
	action_texture.texture = action.texture
	
func _process(_delta: float) -> void:
	if visible:
		info_label.text = _format_action_text()
 
func _format_action_text() -> String:
	if world_object == null:
		return ""
	var regex := RegEx.new()
	regex.compile("\\[\\[(?<placeholder>[^\\[\\]]+)\\]\\]")
	var output = action.info_text
	while output.contains("[["):
		var matches = regex.search(output)
		var value = world_object
		#value = get(matches.strings[1])
		var list_of_attributes:PackedStringArray = matches.strings[1].split(".")
		for attr:String in list_of_attributes:
			value = value.get(attr)
		
		if value is Dictionary: # this will always be an RESOURCE: amount kind of deal
			var outputstr = ""
			for key in value.keys():
				if value[key] > 0:
					outputstr += MyEnums.RESOURCE_TYPES.keys()[key].to_pascal_case()
					outputstr += ": "
					outputstr += str(value[key])
					outputstr += "\n"
			if len(outputstr) > 0:
				outputstr = outputstr.erase(len(outputstr)-1,1)
			output = output.replace(matches.strings[0],outputstr)
		else:
			output = output.replace(matches.strings[0],str(value))
	return output

func _on_button_button_down() -> void:
	var needed_ressource_amount = 0 #TODO handle stuff needing ressources and adding the extra tasks to collect them
	var complex_task:ComplexTask = ComplexTask.constructor(world_object,action)
	action_button_pressed.emit(complex_task)
