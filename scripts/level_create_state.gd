class_name LevelCreateState
extends Resource

const STATE_NAME : String = "LevelCreateState"
const FILE_PATH = "res://scripts/level_create_state.gd"

@export var created_levels : Array = []
@export var total_levels_created : int = 0


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
