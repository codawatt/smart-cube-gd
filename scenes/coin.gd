extends Area2D
class_name Coin

signal unlock_position()

func _ready() -> void:
	set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	set_deferred("monitoring", true)
	
func change_color(color:Color) -> void:
	%Sprite2D.modulate = color

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		unlock_position.emit()
		call_deferred("queue_free")
