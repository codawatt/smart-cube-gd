extends Control

signal level_selected

@onready var level_buttons_container: ItemList = %LevelButtonsContainer
@onready var scene_lister: SceneLister = $SceneLister
var level_paths : Array[String]

func _ready() -> void:
	add_levels_to_container()
	
func add_levels_to_container() -> void:
	level_buttons_container.clear()
	level_paths.clear()
	var game_state := GameState.get_or_create_state()
	var paths: Array[String] = []
	for k in game_state.level_states.keys():
		paths.append(String(k))
	paths.sort_custom(func(a: String, b: String) -> bool:
		return a.get_file().naturalnocasecmp_to(b.get_file()) < 0
	)
	for file_path in paths:
		var file_name: String = file_path.get_file()
		file_name = file_name.trim_suffix(".tres")
		file_name = file_name.replace("_", " ")
		file_name = file_name.capitalize()
		level_buttons_container.add_item(file_name)
		level_paths.append(file_path)

func _on_level_buttons_container_item_activated(index: int) -> void:
	GameState.set_current_level(level_paths[index])
	level_selected.emit()
