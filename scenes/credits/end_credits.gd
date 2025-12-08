class_name ScrollingCredits
extends Credits

@export_file("*.tscn") var main_menu_scene : String

@export var force_mouse_mode_visible : bool = false
@onready var init_mouse_filter : MouseFilter = mouse_filter
@onready var header_space : Control = %HeaderSpace
@onready var footer_space : Control = %FooterSpace
@onready var credits_label : Control = %CreditsLabel
@onready var background_music_player : AudioStreamPlayer = $BackgroundMusicPlayer

func _on_scroll_container_end_reached() -> void:
	%EndMessagePanel.show()
	background_music_player.stop()
	mouse_filter = Control.MOUSE_FILTER_STOP
	if force_mouse_mode_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	end_reached.emit()

func set_header_and_footer() -> void:
	header_space.custom_minimum_size.y = size.y
	footer_space.custom_minimum_size.y = size.y
	credits_label.custom_minimum_size.x = size.x

func _on_MenuButton_pressed() -> void:
	SceneLoader.load_scene(main_menu_scene)

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	if visible:
		background_music_player.play()
		%EndMessagePanel.hide()
		mouse_filter = init_mouse_filter

func _on_resized() -> void:
	set_header_and_footer()


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		background_music_player.play()
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	resized.connect(_on_resized)
	set_header_and_footer()

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.visible:
			_on_scroll_container_end_reached()
		else:
			get_tree().quit()
