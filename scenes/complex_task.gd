extends Node

class_name ComplexTask
const self_scene:PackedScene = preload("res://scenes/complex_task.tscn")

var subtasks:Array[MyEnums.ACTIONS]
var action:ObjectAction
var object:WorldObject
var worker:Worker

var being_worked_on:bool = false
var completed:bool = false

static func constructor(objct:WorldObject,act:ObjectAction) -> ComplexTask:
	var obj := self_scene.instantiate()
	obj.action = act
	obj.object = objct
	obj.subtasks = act.actions
	return obj
