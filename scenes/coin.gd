extends Area2D


signal unlock_position(pos:Vector2i)
@export var color:Color = Color.WHITE
@export var locked_position:Vector2i = Vector2i(999,999)


func _ready() -> void:
	%Sprite2D.modulate = color


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		unlock_position.emit(locked_position) # Replace with function body.
