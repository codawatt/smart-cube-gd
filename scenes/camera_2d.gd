extends Camera2D

@export var MAX_OFFSET: float = 5.0

var _base_offset: Vector2
@onready var _shake_timer: Timer = %ShakeTimer

func _ready() -> void:
	_base_offset = offset
	set_process(false)
	_shake_timer.timeout.connect(_on_shake_done)

func _process(_delta: float) -> void:
	var t := 1.0 - (_shake_timer.time_left / _shake_timer.wait_time) # 0..1
	var intensity := 1.0 - t                                         # 1..0 (damping)
	var random_offset := Vector2(
		randf_range(-MAX_OFFSET, MAX_OFFSET),
		randf_range(-MAX_OFFSET, MAX_OFFSET)
	) * intensity
	offset = _base_offset + random_offset

func _on_main_subtracted() -> void:
	_shake_timer.start()
	set_process(true)

func _on_shake_done() -> void:
	offset = _base_offset
	set_process(false)
