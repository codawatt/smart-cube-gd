@tool
extends StaticBody2D
class_name StaticFloor


enum floor_type {FLOOR, PLATFORM}
@export var v:floor_type

func _ready() -> void:
	match(v):
		floor_type.FLOOR:
			%Sprite2D.texture = preload("res://assets/Floor_margins.png")
		floor_type.PLATFORM:
			%Sprite2D.texture = preload("res://assets/Platform_margins.png")
			
