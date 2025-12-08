extends Sprite2D


@onready var number_label := %NumberLabel
@export var _value = 5
@export var grid: TileMapLayer

func _ready() -> void:
	_update_value()
	get_grid_position()

func _update_value():
	%NumberLabel.text = str(_value)
	
func _decrease_value():
	if _value > 1:
		_value -= 1
		_update_value()
	else:
		queue_free()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_decrease_value()

func get_grid_position():
	if grid == null:
		push_error("TileMapLayer '%GridMap' not found.")
		return

	var local_pos: Vector2 = grid.to_local(global_position)
	var cell: Vector2i = grid.local_to_map(local_pos)

	return cell
