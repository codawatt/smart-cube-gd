@tool
class_name OverlaidMenuContainer
extends OverlaidMenu
#TODO fix this mini overlaid menu container menu mini containers 2 3 4 ?????
@export var menu_scene : PackedScene :
	set(value):
		var _value_changed = menu_scene != value
		menu_scene = value
		if _value_changed:
			for child in %MenuContainer.get_children():
				child.queue_free()
			if menu_scene:
				var _instance = menu_scene.instantiate()
				%MenuContainer.add_child(_instance)
