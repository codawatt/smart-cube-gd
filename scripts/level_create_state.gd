class_name LevelCreateState
extends Resource

const STATE_NAME : String = "LevelCreateState"
const FILE_PATH = "res://scripts/level_create_state.gd"

@export var created_levels : Array = []
@export var total_levels_created : int = 0
@export var current_level_path : String
@export var continue_level_path : String
@export var times_played : int

static func get_level_state(level_state_key : String) -> LevelState:
	if not has_game_state(): 
		return
	var game_state := get_or_create_state()
	if level_state_key.is_empty() : return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key] 
	else:
		var new_level_state := LevelState.new()
		game_state.level_states[level_state_key] = new_level_state
		GlobalState.save()
		return new_level_state

static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)
    
static func get_or_create_state() -> GameState:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)
static func get_current_level_path() -> String:
	if not has_game_state(): 
		return ""
	var game_state := get_or_create_state()
	return game_state.current_level_path

static func create_new_level() -> String:
	var game_state := get_or_create_state()
	game_state.total_levels_created += 1
	#TODO get grid data as param from scene layout and save to level state
	var new_level_path := "res://resources/custom_levels/custom_level_" + str(game_state.total_levels_created) + ".tres"
	game_state.created_levels.append(new_level_path)
	game_state.current_level_path = new_level_path
	GlobalState.save()
	return new_level_path
static func get_levels_reached() -> int:
	if not has_game_state(): 
		return 0
	var game_state := get_or_create_state()
	return game_state.level_states.size()

static func level_reached(level_path : String) -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = level_path
	game_state.continue_level_path = level_path
	get_level_state(level_path)
	GlobalState.save()

static func set_current_level(level_path : String) -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = level_path
	GlobalState.save()

static func start_game() -> void:
	var game_state := get_or_create_state()
	game_state.times_played += 1
	GlobalState.save()

static func continue_game() -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = game_state.continue_level_path
	GlobalState.save()

static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.level_states = {}
	game_state.current_level_path = ""
	game_state.continue_level_path = ""
	GlobalState.save()