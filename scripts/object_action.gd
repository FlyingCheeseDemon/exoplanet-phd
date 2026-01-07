extends Resource

class_name ObjectAction
const ACTIONS = preload("res://scripts/actions.gd")
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

## include variables from the object via [[variable_name]]
## and variables from other objects as [[object.variable_name]]
@export_multiline var info_text:String
@export var action_text:String
@export var texture:Texture
@export var required_resources:Array[RESOURCE_ENUM.RESOURCE_TYPES]
@export var required_resources_amounts:Array[int]

@export var action:ACTIONS.ACTIONS
