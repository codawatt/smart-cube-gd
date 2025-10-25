extends Sprite2D

@export var amplitude: float = 8.0     # pixels
@export var frequency: float = 1    # cycles per second

var _base_y: float

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	position.y = _base_y + oscillate_y(Time.get_ticks_msec() / 2000.0)

func oscillate_y(t: float) -> float:
	# returns an offset in range [-amplitude, +amplitude]
	return amplitude * sin(TAU * frequency * t)
