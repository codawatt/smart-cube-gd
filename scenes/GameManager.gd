extends Control
@onready var grid := %Grid

enum tile_type {EMPTY, PLAYER, FLOOR, PLATFORM, SQUARE}
signal player_next_position(pos:Vector2, strategy:int) # strategy 0 arc, 1 line, 2 arcline
signal subtracted

func _on_player_wish_move(current_position: Vector2, dir: int) -> void:
	#if _two_step:
		#return
	var grid_location :Vector2i = grid.local_to_map(current_position)
	var next_cell := grid_location + Vector2i.RIGHT *dir
	var next_position :Vector2 = grid.map_to_local(next_cell)
	for child in %Elements.get_children():
		if next_cell == grid.local_to_map(child.global_position):
			if child is StaticFloor and child.v == child.floor_type.PLATFORM:
				break
			var upper_cell = next_cell + Vector2i.UP
			next_position = grid.map_to_local(upper_cell)
			#var up_from_current := grid_location + Vector2i.UP
			#var upper_cell := next_cell + Vector2i.UP
			#_two_step = true
			#_queued_final_pos = grid.map_to_local(upper_cell)
			#_queued_arc = 2.0
			emit_signal("player_next_position", next_position,2)
			return
 

	emit_signal("player_next_position",next_position,0)

func _on_check_player_ground(current_position: Vector2):
	var ground :Vector2i = grid.local_to_map(current_position) + Vector2i.DOWN
	var obj:Node = null
	for child in %Elements.get_children():
		if ground == grid.local_to_map(child.global_position):
			obj = child
			if child is NumberSquare:
				call_deferred(child.subtract())
				emit_signal("subtracted")

	if not obj:
		var ground_pos = grid.map_to_local(ground)
		emit_signal("player_next_position", ground_pos, 1)
