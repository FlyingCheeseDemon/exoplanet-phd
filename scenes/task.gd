extends Node

class_name Task
const self_scene:PackedScene = preload("res://scenes/task.tscn")

var action:ObjectAction
var object:WorldObject

var being_worked_on:bool = false
var completed:bool = false

static func constructor(objct:WorldObject,act:ObjectAction) -> Task:
	var obj := self_scene.instantiate()
	obj.action = act
	obj.object = objct
	return obj
