extends Area2D
class_name Minus

signal minus_all

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("minus_all") # Replace with function body.
		queue_free()
