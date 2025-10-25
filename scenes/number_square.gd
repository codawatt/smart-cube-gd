extends StaticBody2D
class_name NumberSquare

signal number_destroyed(number:NumberSquare)
var heat_colors := {
	1: Color(1.0, 0.461, 0.393, 1.0),       # Red (hottest)
	2: Color(1.0, 0.553, 0.359, 1.0),     # Orange-red
	3: Color(1.0, 0.692, 0.23, 1.0),     # Orange
	4: Color(1.0, 0.85, 0.4, 1.0),   # Yellow-orange
	5: Color(1.0, 1.0, 0.31, 1.0),       # Yellow
	6: Color(0.6, 1, 0.4),   # Yellow-green
	7: Color(0.27, 1.0, 0.817, 1.0),   # Green-cyan
	8: Color(0, 0.8, 1),     # Cyan
	9: Color(0, 0.4, 1),     # Blue
	10: Color(0, 0, 1),      # Deep Blue (coldest)     
}
var locked:bool = false
@export var value:int = 4
@onready var lock_sprite := %LockSprite
@onready var square_sprite := %SquareSprite
@onready var number_label := %NumberLabel

func _ready() -> void:
	lock_sprite.hide()
	update_label()
	
func update_label() -> void:
	if value >= 1 and value <= 10:
		square_sprite.modulate = heat_colors[value]
	number_label.text = str(value)
	
func subtract() -> void:
	if not locked:
		value -= 1
		if value <= 0:
			queue_free()
			emit_signal("number_destroyed",self)
		update_label()
func add(_value:int =1) -> void:
	if not locked:
		value += _value
		update_label()
	
func minus() -> void:
	if not locked:
		value -= 1
		if value <= 0:
			queue_free()
		update_label()
	
func lock(color:Color ) -> void:
	lock_sprite.modulate = color
	lock_sprite.show()
	square_sprite.modulate = Color.WEB_GRAY
	locked = true

func unlock() -> void:
	lock_sprite.modulate = heat_colors[value]
	lock_sprite.hide()
	square_sprite = heat_colors[value]
	locked = false
