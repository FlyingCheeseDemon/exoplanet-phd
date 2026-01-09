extends Node

class_name Task
const self_scene:PackedScene = preload("res://scenes/task.tscn")

var action:ObjectAction

var completed:bool = false

static func constructor(act:ObjectAction) -> Task:
	var obj := self_scene.instantiate()
	obj.action = act
	return obj
