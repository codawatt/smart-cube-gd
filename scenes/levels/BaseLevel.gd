extends Node
class_name BaseLevel

signal level_lost
signal level_won
signal level_won_and_changed(level_path : String)

@export_file("*.tscn") var next_level_path_scene : String
@export_file("*.tres") var next_level_path : String
@export_file("*.tres") var level_path : String = ""  # injected by LevelLoader; identifies the current LevelData
 
var level_state : LevelState

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	if not next_level_path.is_empty():
		level_won_and_changed.emit(next_level_path)
	else:
		level_won.emit()

func open_tutorials() -> void:
	#%TutorialManager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()

func _ready() -> void:
	# Prefer the LevelData path as the state key (same scene reused for many data files).
	var state_key := level_path if not level_path.is_empty() else scene_file_path
	level_state = GameState.get_level_state(state_key)
	#%ColorPickerButton.color = level_state.color
	#%BackgroundColor.color = level_state.color
	if not level_state.tutorial_read:
		open_tutorials()

func _on_color_picker_button_color_changed(color : Color) -> void:
	#%BackgroundColor.color = color
	level_state.color = color
	GlobalState.save()

func _on_tutorial_button_pressed() -> void:
	open_tutorials()
