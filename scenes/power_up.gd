extends Area2D
class_name PowerUp

signal apply_effect(val:int)
signal power_up_changed

@export var amount: int = 1

func _ready() -> void:
	set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	set_deferred("monitoring", true)

func change_power_up(selected_power_up:int) -> void:
	match(selected_power_up):
		1:
			amount = 1
		-1:
			amount = -1
	power_up_changed.emit()
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		apply_effect.emit(amount)
		queue_free()
