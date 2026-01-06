extends Node

class_name Task
const self_scene:PackedScene = preload("res://scenes/task.tscn")

var action:ObjectAction
var object:WorldObject

static func constructor(object:WorldObject,action:ObjectAction) -> Task:
	var obj := self_scene.instantiate()
	obj.action = action
	obj.object = object
	return obj
