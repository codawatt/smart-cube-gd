extends StaticBody2D
class_name NumberSquare

signal number_destroyed(number:NumberSquare)
var heat_colors := {
	1: Color(1.0, 0.461, 0.393, 1.0),     
	2: Color(1.0, 0.553, 0.359, 1.0),   
	3: Color(1.0, 0.692, 0.23, 1.0),  
	4: Color(1.0, 0.85, 0.4, 1.0),  
	5: Color(1.0, 1.0, 0.31, 1.0),      
	6: Color(0.6, 1, 0.4),  
	7: Color(0.27, 1.0, 0.817, 1.0),  
	8: Color(0, 0.8, 1),     
	9: Color(0, 0.4, 1), 
	10: Color(0, 0, 1),     
}
var locked:bool = false
@export var value:int = 4

func change_value(val:int):
	if val >= 1 and value <= 10:
		value = val
		update_label()
	
func update_label() -> void:
	if value >= 1 and value <= 10:
		%SquareSprite.modulate = heat_colors[value]
	%NumberLabel.text = str(value)
	
func subtract() -> void:
	if not locked:
		value -= 1
		if value <= 0:
			queue_free()
			emit_signal("number_destroyed",self)
		update_label()
func power_up(_value:int =1) -> void:
	if not locked:
		value += _value
		if value <= 0:
			queue_free()
		update_label()

	
func lock(color:Color) -> void:
	%LockSprite.modulate = color
	%LockSprite.show()
	%SquareSprite.modulate = Color.WEB_GRAY
	locked = true

func unlock() -> void:
	locked = false
	%LockSprite.modulate = heat_colors[value]
	%LockSprite.hide()
	%SquareSprite.modulate = heat_colors[value]
	update_label()
