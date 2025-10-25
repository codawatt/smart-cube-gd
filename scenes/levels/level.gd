
#dictionary vectors can't exceed 15 on x or 8 on y or below 0 in map
#cannot add type player more than once on map
extends BaseLevel
class_name Level

@export var elements_packed:Dictionary[String, PackedScene]

var enable_lava:bool = false
var first_move:bool = false
var number_sum:int = 0
var map:Dictionary # Dictionary[Vector2i, Dictionary[packedscene,
var player:Player
var number_arr:Array[NumberSquare] = []

@onready var elements: Node2D = %Elements 
@onready var grid: TileMapLayer = %Grid
@onready var camera: Camera2D = %SceneCamera
@onready var lava: liquid = %Liquid

signal player_next_position(pos:Vector2, strategy:int) # strategy 0 arc, 1 line, 2 arcline
signal subtracted

func _ready() -> void:
	#map[Vector2i(9, 4)] = elements_packed["Player"]
	#map[Vector2i(7, 4)] = elements_packed["Number"]
	#map[Vector2i(13, 4)] = elements_packed["Floor"]
	#map[Vector2i(13, 3)] = elements_packed["Plus"]
	#map[Vector2i(8, 5)] = elements_packed["Number"]
	#map[Vector2i(9, 5)] = elements_packed["Floor"]
	#map[Vector2i(10, 5)] = elements_packed["Number"]
	#map[Vector2i(11, 5)] = elements_packed["Number"]
	#map[Vector2i(12, 5)] = elements_packed["Number"]
	
	map[Vector2i(9, 4)] = elements_packed["Player"]
	_add_number_tile(Vector2i(7, 4),3)
	map[Vector2i(13, 4)] = elements_packed["Floor"]
	map[Vector2i(13, 3)] = elements_packed["Plus"]
	_add_number_tile(Vector2i(8, 4),3)
	map[Vector2i(9, 5)] = elements_packed["Floor"]
	_add_number_tile(Vector2i(10, 5),2)
	_add_number_tile(Vector2i(11, 5),1)
	_add_number_tile(Vector2i(12, 5),3)
	connect("subtracted",Callable(camera, "_on_main_subtracted"))

	_set_default_values()
	_generate_map()
	_signal_connections()
func _set_default_values():
	number_sum = 0
	enable_lava = true
	first_move = false
func restart():
	_set_default_values()
	_clean_map_elements()
	_generate_map()
	_signal_connections()
	lava.restart()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed("restart"):
		restart()
	if event is InputEvent and event.is_action_pressed("debug_add"):
		add_to_numbers()
	if event is InputEvent and event.is_action_pressed("debug_subtract"):
		remove_to_numbers()
func _clean_map_elements() -> void:
	if is_instance_valid(elements):
		for c in elements.get_children():
			c.queue_free()
func _generate_map() -> void:
	#_clean_map_elements()
	number_arr = []
	for cell: Vector2i in map.keys():
		var scene: PackedScene = map[cell]
		if scene == null:
			continue

		var inst := scene.instantiate()
		if inst is NumberSquare:
			#number_sum += inst.value
			#number_arr.append(inst)
			continue
		if inst is Player:
			player = inst
		if inst is Minus:
			inst.connect("minus_all", Callable(self,"remove_to_numbers"))
		if inst is Plus:
			inst.connect("plus_all", Callable(self,"add_to_numbers"))
		if inst == null:
			continue
	
		elements.add_child(inst)
		var local_pos: Vector2 = grid.map_to_local(cell)
		var global_pos: Vector2 = grid.to_global(local_pos)
		inst.global_position = global_pos
		
func _on_player_wish_move(current_position: Vector2, dir: int) -> void:
	if enable_lava and not first_move:
		first_move = true
		lava.start()
	var grid_location :Vector2i = grid.local_to_map(current_position)
	var next_cell := grid_location + Vector2i.RIGHT * dir
	var next_position :Vector2 = grid.map_to_local(next_cell)
	for child in elements.get_children():
		if child is Player:
			continue
		if next_cell == grid.local_to_map(child.global_position):
			if child is StaticFloor and child.v == child.floor_type.PLATFORM:
				break
			var upper_cell = next_cell + Vector2i.UP
			next_position = grid.map_to_local(upper_cell)
			emit_signal("player_next_position", next_position,2)
			return
 
	emit_signal("player_next_position",next_position,0)
func _on_check_player_ground(current_position: Vector2):
	var ground :Vector2i = grid.local_to_map(current_position) + Vector2i.DOWN
	var obj:Node = null
	for child in elements.get_children():
		if child is Player:
			continue
		if ground == grid.local_to_map(child.global_position):
			obj = child
			if obj is NumberSquare:
				obj.subtract()
				number_sum -= 1;
				subtracted.emit() #TODO change all emit_signals("name") to name.emit()
				print(number_sum)
				if number_sum == 0:
					player.can_move = false
					lava.tw.kill()
					level_won.emit()
	if not obj:
		var ground_pos = grid.map_to_local(ground)
		emit_signal("player_next_position", ground_pos, 1)

func _add_number_tile(pos: Vector2i, value: int) -> void:
	if pos.x < 0 or pos.y < 0 or pos.x > 15 or pos.y > 8:
		push_error("Number tile out of bounds: %s" % [pos])
		return

	var number_scene: PackedScene = elements_packed.get("Number")
	if number_scene == null:
		push_error("Missing 'Number' scene in elements_packed.")
		return

	var inst: NumberSquare = number_scene.instantiate() as NumberSquare
	if inst == null:
		push_error("'Number' scene does not instantiate a NumberSquare.")
		return

	# (optional) don't place two numbers on the same cell
	for child in elements.get_children():
		if child is NumberSquare and grid.local_to_map(child.global_position) == pos:
			push_warning("A NumberSquare already exists at %s; skipping." % [pos])
			return

	inst.value = value
	number_sum += inst.value
	number_arr.append(inst)
	elements.add_child(inst)

	var local_pos: Vector2 = grid.map_to_local(pos)
	inst.global_position = grid.to_global(local_pos)

func _signal_connections():
	player.connect("wish_move",Callable(self,"_on_player_wish_move"))
	player.connect("check_ground",Callable(self,"_on_check_player_ground"))
	lava.connect("body_entered", Callable(player,"_on_liquid_body_entered"))
	connect("player_next_position", Callable(player,"_on_main_player_next_position"))
	for nr in number_arr:
		nr.connect("number_destroyed",Callable(player,"_on_number_destroyed"))
		nr.connect("number_destroyed",Callable(self,"_on_number_destroyed"))
		
func _on_number_destroyed(number:NumberSquare):
	number_arr.erase(number)
	

func add_to_numbers():
	for nr in number_arr:
		if is_instance_valid(nr):
			nr.add()
func remove_to_numbers():
	for nr in number_arr:
		if is_instance_valid(nr):
			nr.minus()
