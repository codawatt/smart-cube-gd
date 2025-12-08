extends Control
class_name LevelBanner

@onready var label: RichTextLabel = $Label

# ——— Tunables (show up in Inspector) ———
@export_group("Timing")
@export var slide_duration: float = 0.35
@export var hold_duration: float = 0.60
@export var fade_duration: float = 0.40
@export var start_delay: float = 0.00   # optional pause before the slide

@export_group("Easing")
@export var transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var ease: Tween.EaseType = Tween.EASE_OUT

@export_group("Positioning")
@export var target_y: float = 16.0      # Y position once visible (top padding)
@export var start_y_offset: float = 0.0 # extra offset above screen, added to -size.y
@export var center_horizontally: bool = true

@export_group("Visuals")
@export var start_opacity: float = 1.0  # 1.0 = fully visible during slide
@export var end_opacity: float = 0.0    # 0.0 = fully transparent at end
@export var auto_free: bool = true      # delete self after anim

## Public API
func show_banner(level_number: int) -> void:
	label.bbcode_text = "[center]Level %d[/center]" % level_number
	# Ensure layout is ready before measuring/animating
	await get_tree().process_frame

	# Horizontal centering (optional)
	if center_horizontally:
		position.x = (get_viewport_rect().size.x - size.x) * 0.5

	# Start just above the top (off-screen)
	position.y = -size.y - start_y_offset
	modulate.a = clampf(start_opacity, 0.0, 1.0)
	visible = true

	var tw := create_tween()
	tw.set_trans(transition).set_ease(ease)

	# Optional initial delay
	if start_delay > 0.0:
		tw.tween_interval(start_delay)

	# Slide into top-center
	tw.tween_property(self, "position:y", target_y, max(0.0, slide_duration))
	# Briefly stay on screen
	if hold_duration > 0.0:
		tw.tween_interval(hold_duration)
	# Fade out
	tw.tween_property(self, "modulate:a", clampf(end_opacity, 0.0, 1.0), max(0.0, fade_duration))

	await tw.finished
	if auto_free:
		queue_free()
