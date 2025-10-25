extends Area2D
class_name Plus

signal plus_all

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("plus_all") # Replace with function body.
		queue_free()
