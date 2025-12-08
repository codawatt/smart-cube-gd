extends Node


@export var pause_menu_packed : PackedScene
@export var focused_viewport : Viewport
@export var mob_ui:MobileUi

func _ready() -> void:
	if mob_ui:
		mob_ui.open_menu.connect(open_pause_menu)
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()

func open_pause_menu():
	if not focused_viewport:
		focused_viewport = get_viewport()
	var _initial_focus_control = focused_viewport.gui_get_focus_owner()
	var current_menu = pause_menu_packed.instantiate()
	get_tree().current_scene.call_deferred("add_child", current_menu)
	await current_menu.tree_exited
	if is_inside_tree() and _initial_focus_control:
		_initial_focus_control.grab_focus()
