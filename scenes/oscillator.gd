extends Sprite2D
class_name SpriteOscillator

@export var amplitude: float = 8.0     
@export var frequency: float = 1   

var _base_y: float

func _ready() -> void:
	_base_y = position.y
	frequency = randf()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	position.y = _base_y + oscillate_y(Time.get_ticks_msec() / 2000.0)

func oscillate_y(t: float) -> float:
	return amplitude * sin(TAU * frequency * t)
