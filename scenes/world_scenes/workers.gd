extends Node

@onready var free_workers:Node = $FreeWorkers

func _on_task_started(worker:Worker):
	worker.reparent(self)
	print("Free workers:")
	print(free_workers.get_child_count())
	
func _on_task_ended(worker:Worker):
	worker.reparent(free_workers)
	print("Free workers:")
	print(free_workers.get_child_count())
