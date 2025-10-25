extends Node

static var level_sum :int = 0

signal sum_depleted

func add_to_sum(value:int) -> void:
	level_sum += value
	

func remove_from_sum(value:int) -> void:
	level_sum -= value
	if level_sum <= 0:
		emit_signal("sum_depleted")
	
func reset_sum():
	level_sum = 0
