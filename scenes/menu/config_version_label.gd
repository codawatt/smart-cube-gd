@tool
extends Label
class_name ConfigVersionLabel

const NO_VERSION_STRING : String = "0.0.0"

@export var version_prefix : String = "v"

func update_version_label() -> void:
	var config_version : String = ProjectSettings.get_setting("application/config/version", NO_VERSION_STRING)
	if config_version.is_empty():
		config_version = NO_VERSION_STRING
	text = version_prefix + config_version

func _ready() -> void:
	update_version_label()
