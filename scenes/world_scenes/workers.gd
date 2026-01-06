extends Node

var free_workers:Array[Worker] = []

func _on_task_started(worker:Worker):
	free_workers.erase(worker)
	
func _on_task_ended(worker:Worker):
	free_workers.append(worker)
	if worker.current_task != null:
		worker.current_task.queue_free()
