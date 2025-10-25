# MobileUI.gd
extends Control
@export var hide_on_desktop := true

func _ready() -> void:
	# Touch capability (works on Android/iOS, and can be detected on Web)
	var has_touch := DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN)
	# Platform buckets:
	var is_mobile_native := OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("mobile")
	var is_mobile_web := OS.has_feature("web_android") or OS.has_feature("web_ios")

	var should_show := has_touch or is_mobile_native or is_mobile_web
	visible = (not hide_on_desktop) or should_show


func _on_left_button_pressed() -> void:
	Input.action_press("ui_left") # Replace with function body.
	Input.action_release("ui_left")

func _on_right_button_pressed() -> void:
	Input.action_press("ui_right") # Replace with function body.
	Input.action_release("ui_right")
