@tool
extends StaticBody2D
class_name StaticFloor

var walk_under:bool = false

func change_type(selected_type:int) -> void:
	match(selected_type):
		0:
			%Sprite2D.texture = preload("res://assets/Floor_margins.png")
			walk_under = false
		1:
			%Sprite2D.texture = preload("res://assets/Platform_margins.png")
			walk_under = true
			
