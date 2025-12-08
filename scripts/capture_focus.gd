extends Control

@export var search_depth : int = 1
@export var enabled : bool = false
@export var null_focus_enabled : bool = true
@export var joypad_enabled : bool = true
@export var mouse_hidden_enabled : bool = true
@export var home_end_enabled : bool = false

@export var lock : bool = false :
	set(value):
		var value_changed : bool = lock != value
		lock = value
		if value_changed and not lock:
			update_focus()

var _home_target : Control = null
var _end_target : Control = null

@onready var _ref = self

func _focus_first_search(control_node : Control, levels : int = 1) -> bool:
	if control_node == null or !control_node.is_visible_in_tree():
		return false
	if control_node.focus_mode == FOCUS_ALL:
		control_node.grab_focus()
		if control_node is ItemList:
			control_node.select(0)
		return true
	if levels < 1:
		return false
	var children = control_node.get_children()
	for child in children:
		if _focus_first_search(child, levels - 1):
			return true
	return false

func focus_first() -> void:
	_focus_first_search(self, search_depth)

func update_focus() -> void:
	if lock : return
	if _is_visible_and_should_capture():
		focus_first()

func _should_capture_focus() -> bool:
	return enabled or \
	(get_viewport().gui_get_focus_owner() == null and null_focus_enabled) or \
	(Input.get_connected_joypads().size() > 0 and joypad_enabled) or \
	(Input.mouse_mode not in [Input.MOUSE_MODE_VISIBLE, Input.MOUSE_MODE_CONFINED] and mouse_hidden_enabled)

func _is_visible_and_should_capture() -> bool:
	return is_visible_in_tree() and _should_capture_focus()

func _on_visibility_changed() -> void:
	call_deferred("update_focus")
	if home_end_enabled:
		call_deferred("_refresh_home_end_targets")
func _ready() -> void:
	if is_inside_tree():
		update_focus()
		connect("visibility_changed", _on_visibility_changed)
	if home_end_enabled and _ref is BoxContainer:
		connect("child_entered_tree", _on_children_node_changed)
		connect("child_exiting_tree", _on_children_node_changed)
		connect("child_order_changed", _on_children_order_changed)
		_refresh_home_end_targets()

func _on_children_order_changed() -> void:
	if home_end_enabled:
		_refresh_home_end_targets()
func _on_children_node_changed(_node:Node) -> void:
	if home_end_enabled:
		_refresh_home_end_targets()

func _refresh_home_end_targets() -> void:
	_home_target = null
	_end_target = null
	if !(_ref is BoxContainer):
		return
	var focusables : Array[Control] = []
	for child in get_children():
		_collect_focusables(child, focusables)
	if focusables.size() > 0:
		_home_target = focusables.front()
		_end_target = focusables.back()

func _collect_focusables(node: Node, out: Array) -> void:
	if node is Control:
		var c: Control = node
		if c.is_visible_in_tree() and c.focus_mode == FOCUS_ALL:
			out.append(c)
	for ch in node.get_children():
		_collect_focusables(ch,out)
		
func _unhandled_input(event: InputEvent) -> void:
	if !home_end_enabled or !(_ref is BoxContainer):
		return

	# Rebuild targets whenever we try to use Home/End
	if event.is_action_pressed("ui_home") or event.is_action_pressed("ui_end"):
		_refresh_home_end_targets()

	if event.is_action_pressed("ui_home") and _home_target:
		_home_target.grab_focus()
		if _home_target is ItemList:
			_home_target.select(0)
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_end") and _end_target:
		_end_target.grab_focus()
		if _end_target is ItemList:
			var count : int = _end_target.get_item_count() if _end_target.has_method("get_item_count") else _end_target.item_count
			if count > 0:
				_end_target.select(count - 1)
		get_viewport().set_input_as_handled()
