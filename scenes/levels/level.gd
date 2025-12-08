
extends BaseLevel
class_name Level

@export var elements_packed:Dictionary[String, PackedScene]
@export var level_data:LevelData = null

@export var number_square_scene:PackedScene = preload("res://scenes/number_square.tscn")
@export var platform_scene:PackedScene = preload("res://scenes/floor.tscn")
@export var coin_scene:PackedScene = preload("res://scenes/coin.tscn")
@export var powerup_scene:PackedScene = preload("res://scenes/power_up.tscn")
@export var player_scene:PackedScene = preload("res://scenes/player.tscn")

var lock_colors := {
	1: Color(1.0, 0.85, 0.0, 1.0),     
	2: Color(0.0, 0.133, 1.0, 1.0),   
	3: Color(0.064, 0.912, 0.0, 1.0),  
}
var enable_lava:bool = false
var first_move:bool = false
var number_sum:int = 0
var map:Dictionary 
var player:Player
var number_arr:Array[NumberSquare] = []
var number_dict:Dictionary[Vector2i,NumberSquare]
@onready var elements: Node2D = %Elements 
@onready var grid: TileMapLayer = %Grid
@onready var camera: Camera2D = %SceneCamera
@onready var lava: liquid = %Liquid

signal player_next_position(pos:Vector2, strategy:int) # strategy 0 arc, 1 line, 2 arcline
signal subtracted

func _ready() -> void:
	var ui:MobileUi= get_tree().get_first_node_in_group("ui") as MobileUi
	if ui:
		ui.level = self
	if level_data == null:
		push_error("Level: level_data is null. Make sure LevelLoader sets it before adding to the tree.")
	_generate_map_from_resource()
	connect("subtracted",Callable(camera, "_on_main_subtracted"))
	_set_default_values()
	_signal_connections()
	
func _set_default_values():
	enable_lava = true
	first_move = false
func restart():
	_clean_map_elements()
	_generate_map_from_resource()
	_set_default_values()
	_signal_connections()
	lava.restart()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed("restart"):
		restart()
	if event is InputEvent and event.is_action_pressed("debug_add"):
		_apply_power_up(1)
	if event is InputEvent and event.is_action_pressed("debug_subtract"):
		_apply_power_up(-1)
func _clean_map_elements() -> void:
	if is_instance_valid(elements):
		for c in elements.get_children():
			c.queue_free()

func _generate_map_from_resource():
	_generate_numbers()
	_generate_platforms()
	_generate_coins()
	_generate_powerups()
	_add_player()
func _generate_numbers():
	number_arr = []
	number_dict = {}
	number_sum = 0
	for number in level_data.stage_numbers:
		var number_inst:NumberSquare= instantiate_to_grid(number_square_scene,number)
		number_inst.change_value(level_data.stage_numbers[number])
		number_sum += number_inst.value
		number_dict[number] = number_inst
	
func _generate_platforms():
	for platform in level_data.stage_platforms:
		var platform_inst:StaticFloor = instantiate_to_grid(platform_scene, platform)
		platform_inst.change_type(level_data.stage_platforms[platform]) 
		
func _generate_coins():
	#for color in lock_colors: # iterate all colors, if there is a coin up to three in level_data.stage_coins they will be 
	var color_keys := lock_colors.keys()
	color_keys.sort()
	var index := 0
	
	for coin in level_data.stage_coins:
		if index >= color_keys.size():
			break
			
		var coin_inst:Coin = instantiate_to_grid(coin_scene, coin)
		if number_dict.has(level_data.stage_coins[coin]):
			var number_inst:= number_dict[level_data.stage_coins[coin]]
			coin_inst.unlock_position.connect(number_inst.unlock)
			var color :Color = lock_colors[color_keys[index]]
			number_inst.lock(color)
			coin_inst.change_color(color)
		else:
			coin_inst.call_deferred("queue_free")
		index+=1


func _generate_powerups(): 
	for powerup in level_data.stage_powerups:
		var power_up_inst:PowerUp = instantiate_to_grid(powerup_scene, powerup)
		power_up_inst.change_power_up(level_data.stage_powerups[powerup])
		power_up_inst.apply_effect.connect(_apply_power_up)
func _add_player():
	player = instantiate_to_grid(player_scene,level_data.player_start)
	
func instantiate_to_grid(scene:PackedScene,grid_pos:Vector2i):
	var inst := scene.instantiate()	
	elements.add_child(inst)
	var local_pos: Vector2 = grid.map_to_local(grid_pos)
	var global_pos: Vector2 = grid.to_global(local_pos)
	inst.global_position = global_pos
	return inst
	
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
			if child is StaticFloor and child.walk_under:
				break
			if child is Coin:
				break
			if child is PowerUp:
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
		if child is Coin:
			break
		if child is PowerUp:
			break
		if ground == grid.local_to_map(child.global_position):
			obj = child
			if obj is NumberSquare and not obj.locked:
				obj.subtract()
				number_sum -= 1;
				subtracted.emit() #TODO change all emit_signals("name") to name.emit()
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
	for nr in number_dict:
		number_dict[nr].connect("number_destroyed",Callable(player,"_on_number_destroyed"))
		number_dict[nr].connect("number_destroyed",Callable(self,"_on_number_destroyed"))
		
func _on_lava_body_entered(body: Node) -> void:
	if body is Player:
		player.can_move = false
		level_lost.emit()
		
func _on_number_destroyed(number:NumberSquare):
	var number_key = number_dict.find_key(number)
	number_dict.erase(number_key)
	
	
func _apply_power_up(value:int):
	number_sum += number_dict.size() * value
	for nr in number_dict:
		if is_instance_valid(number_dict[nr]):
			number_dict[nr].power_up(value)
