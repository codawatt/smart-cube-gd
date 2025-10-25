# Godot 4.x
# Attach to a Node2D or Sprite2D. Position is treated as center (pivot).
extends Area2D
class_name liquid

@export var start_position:Vector2 = Vector2(512,846)
@export var end_position:Vector2 = Vector2(512,288)
@export var start_delay: float = 0.0               # seconds before rising
@export var rise_duration: float = 50              # seconds to reach end_pos
@export var trans: Tween.TransitionType = Tween.TRANS_SINE
@export var easing: Tween.EaseType = Tween.EASE_OUT
@onready var viewport_size := get_viewport().get_visible_rect().size

var tw: Tween;
func start() -> void:
	global_position = start_position
	
	await get_tree().create_timer(start_delay).timeout
	tw = create_tween()
	tw.set_trans(trans).set_ease(easing)
	tw.tween_property(self, "global_position", end_position, rise_duration)
func restart():
	tw.kill()
	global_position = start_position
	
