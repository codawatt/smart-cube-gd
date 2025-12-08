extends Area2D


@export var _map: TileMapLayer

const CELL_OFFSET: Vector2 = Vector2(32,0)
const DOWN_DIR: Vector2i = Vector2i(0,1)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_move_by(Vector2i(-1, 0))
	if event.is_action_pressed("move_right"):
		_move_by(Vector2i(1, 0))

func _get_current_cell():
	if not _map:
		return
	return _map.local_to_map(global_position)
	
func _move_by(offset:Vector2i):
	var cell = _get_current_cell()
	var target = cell + offset
	if _map.get_cell_tile_data(target):
		target.y -= 1
		

	var world_pos = _map.map_to_local(target)
	global_position = world_pos - CELL_OFFSET 
