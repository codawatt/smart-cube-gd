extends CharacterBody2D
class_name Player

var _p0: Vector2
var _p1: Vector2
var _pc: Vector2
var _move_tween: Tween
var can_move:bool = true
var _active_tweens: Array[Tween] = []
var last_strategy:int = 0
var move_duration:float = 0.21
var fall_duration:float = 0.21
var accel:float = 0.08
var coyote_time :float= 0.5
signal wish_move(current_position:Vector2,dir:int)
signal check_ground(current_position:Vector2)

var _buffered_dir: int = 0
var ui:MobileUi =null

func _physics_process(_delta: float) -> void:
	if can_move and _buffered_dir != 0:
		emit_signal("wish_move", global_position, _buffered_dir)
		_buffered_dir = 0

func _ready() -> void:
	var found := get_tree().root.find_children("*", "MobileUi", true, false)
	if not found.is_empty():
		ui = found[0] as MobileUi
		ui.player = self
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left", true):
		_buffer_move(-1)
	elif event.is_action_pressed("move_right", true):
		_buffer_move(1)

func ui_press_right():
	_buffer_move(1)

func ui_press_left():
	_buffer_move(-1)

func _buffer_move(dir: int) -> void:
	# last input wins
	_buffered_dir = dir

func _on_main_player_next_position(pos: Vector2, strategy: int) -> void:
	if not can_move:
		return
	_move_strategy(pos,strategy)

func _on_number_destroyed(_number:NumberSquare):
	var save_position := global_position
	await get_tree().create_timer(coyote_time).timeout
	if global_position != save_position:
		return
	emit_signal("check_ground",global_position)

func move_parabolic(next_position: Vector2, duration: float = 1, arc_height: float = 64.0) -> Tween:
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()

	_p0 = global_position
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

func _apply_parabola(t: float) -> void:
	var u := 1.0 - t
	# Quadratic Bézier interpolation: B(t) = (1-t)^2 P0 + 2(1-t)t Pc + t^2 P1
	var pos := u * u * _p0 + 2.0 * u * t * _pc + t * t * _p1
	global_position = pos


func _on_liquid_body_entered(body: Node2D) -> void:
	if body == self:
		kill_all_player_tweens()
		can_move = false
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

func move_linear(next_position: Vector2, duration: float = 0.1) -> Tween:
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()

	_p0 = global_position
	_p1 = next_position

	var delta := _p1 - _p0
	if delta.length() < 0.001:
		global_position = _p1
		return null

	var t := create_tween()
	_track(t)
	t\
		.tween_method(_apply_linear, 0.0, 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)
	return t

func _apply_linear(t: float) -> void:
	global_position = _p0.lerp(_p1, t)

func _move_strategy(next_pos:Vector2, strategy:int):
	can_move = false
	match strategy:
		0:
			last_strategy = 0
			await move_parabolic(next_pos,move_duration).finished
			
		1:
			if last_strategy != 1:
				last_strategy = 1
				fall_duration = 0.3
				await move_linear(next_pos,fall_duration).finished
			else:
				if fall_duration >0.1:
					fall_duration -= accel
				else:
					fall_duration = 0.1
				await move_linear(next_pos,fall_duration).finished
		2:
			last_strategy = 2
			var step_pos := next_pos
			step_pos.x = global_position.x
			await move_linear(step_pos, move_duration *0.5).finished
			await move_parabolic(next_pos, move_duration *0.5).finished
	can_move = true
	emit_signal("check_ground",global_position)
