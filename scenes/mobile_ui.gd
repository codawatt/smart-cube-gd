# MobileUI.gd
extends Control
class_name MobileUi
signal open_menu
@export var hide_on_desktop := true
var player:Player = null
var level:Level = null
func _ready() -> void:
	var has_touch := DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN)
	var is_mobile_native := OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("mobile")
	var is_mobile_web := OS.has_feature("web_android") or OS.has_feature("web_ios")

	var should_show := has_touch or is_mobile_native or is_mobile_web
	visible = (not hide_on_desktop) or should_show


func _on_left_button_button_down() -> void:
	if player:
		player.ui_press_left()

func _on_right_button_button_down() -> void:
	if player:
		player.ui_press_right()


func _on_restart_button_button_down() -> void:
	level.restart() # Replace with function body.


func _on_menu_button_button_down() -> void:
	open_menu.emit() # Replace with function body.
