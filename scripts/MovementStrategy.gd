extends Node2D
class_name MovementStrategy


var _p0: Vector2
var _p1: Vector2
var _pc: Vector2
var _move_tween: Tween
var can_move:bool = true
var _active_tweens: Array[Tween] = []

func move_parabolic(node:Node2D, next_position: Vector2, duration: float = 1, arc_height: float = 60.0) -> Tween:
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()

	_p0 = node.global_position
	_p1 = next_position

	var delta := _p1 - _p0
	if delta.length() < 0.001:
		global_position = _p1
		return null

	var mid := (_p0 + _p1) * 0.5
	_pc = mid + Vector2(0, -abs(arc_height))

	_move_tween = create_tween()
	_track(_move_tween)
	_move_tween\
		.tween_method(_apply_parabola, 0.0, 1.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	return _move_tween

func _apply_parabola(node:Node2D,t: float) -> void:
	var u := 1.0 - t
	# Quadratic Bézier interpolation: B(t) = (1-t)^2 P0 + 2(1-t)t Pc + t^2 P1
	var pos := u * u * _p0 + 2.0 * u * t * _pc + t * t * _p1
	node.global_position = pos

func _track(t: Tween) -> void:
	_active_tweens.append(t)
	t.finished.connect(func():
		_active_tweens.erase(t)
)
func kill_all_player_tweens() -> void:
	for t in _active_tweens.duplicate():
		if is_instance_valid(t):
			t.kill()
	_active_tweens.clear()
