class_name MainMenu
extends Control

signal sub_menu_opened
signal sub_menu_closed
signal game_started
signal game_exited

## Defines the path to the game scene. Hides the play button if empty.
@export_file("*.tscn") var game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export var level_select_packed_scene: PackedScene
@export_group("Extra Settings")
@export var signal_game_start : bool = false
@export var signal_game_exit : bool = false
@export var confirm_new_game : bool = true

var options_scene
var credits_scene
var sub_menu
var level_select_scene : Node
var animation_state_machine : AnimationNodeStateMachinePlayback

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var new_game_button = %NewGameButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var options_container = %OptionsContainer
@onready var credits_container = %CreditsContainer
@onready var flow_control_container = %FlowControlContainer
@onready var back_button = %BackButton
@onready var continue_game_button = %ContinueGameButton
@onready var level_select_button = %LevelSelectButton
@onready var level_select_container = %LevelSelectContainer

func load_game_scene() -> void:
	GameState.start_game() 
	if signal_game_start:
		SceneLoader.load_scene(game_scene_path, true)
		game_started.emit()
	else:
		SceneLoader.load_scene(game_scene_path)

func new_game() -> void:
	if confirm_new_game and GameState.has_game_state():
		%NewGameConfirmationDialog.popup_centered()
	else:
		GameState.reset()
		load_game_scene()

func exit_game() -> void:
	if OS.has_feature("web"):
		return
	if signal_game_exit:
		game_exited.emit()
	else:
		get_tree().quit()

func _hide_menu() -> void:
	flow_control_container.show()
	back_button.show()
	menu_container.hide()

func _show_menu() -> void:
	back_button.hide()
	flow_control_container.hide()
	menu_container.show()

func _open_sub_menu(menu : Control) -> void:
	sub_menu = menu
	sub_menu.show()
	_hide_menu()
	sub_menu_opened.emit()
	#animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	_show_menu()
	sub_menu_closed.emit()
	#animation_state_machine.travel("OpenMainMenu")

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			exit_game()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _hide_new_game_if_unset() -> void:
	if game_scene_path.is_empty():
		new_game_button.hide()

func _add_or_hide_options() -> void:
	if options_packed_scene == null:
		options_button.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		options_container.show()
		options_container.call_deferred("add_child", options_scene)

func _add_or_hide_credits() -> void:
	if credits_packed_scene == null:
		credits_button.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		credits_container.show()
		credits_container.call_deferred("add_child", credits_scene)

func _ready() -> void:
	#flow_control_container.show()
	_hide_exit_for_web()
	_add_or_hide_options()
	_add_or_hide_credits()
	_hide_new_game_if_unset()
	_add_level_select_if_set()
	_show_continue_if_set()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _on_new_game_button_pressed() -> void:
	new_game()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)

func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_scene)

func _on_exit_button_pressed() -> void:
	exit_game()

func _on_credits_end_reached() -> void:
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed() -> void:
	_close_sub_menu()

#abandon all hope the who enters below
func intro_done() -> void:
	#animation_state_machine.travel("OpenMainMenu")
	pass
func _is_in_intro() -> bool:
	return animation_state_machine.get_current_node() == "Intro"
func _event_skips_intro(event : InputEvent) -> bool:
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)
func _add_level_select_if_set() -> void: 
	if level_select_packed_scene == null: return
	if GameState.get_levels_reached() <= 1 : return
	level_select_scene = level_select_packed_scene.instantiate()
	level_select_scene.hide()
	level_select_container.show()
	level_select_container.call_deferred("add_child", level_select_scene)
	if level_select_scene.has_signal("level_selected"):
		level_select_scene.connect("level_selected", load_game_scene)
	level_select_button.show()

func _show_continue_if_set() -> void:
	if GameState.has_game_state():
		continue_game_button.show()

func _on_continue_game_button_pressed() -> void:
	GameState.continue_game()
	load_game_scene()

func _on_level_select_button_pressed() -> void:
	_open_sub_menu(level_select_scene)

func _on_new_game_confirmation_dialog_confirmed():
	GameState.reset()
	load_game_scene()
