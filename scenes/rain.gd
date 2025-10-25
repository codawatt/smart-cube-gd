extends Node2D

# Diagonal minimalist rain: top edge emitter, drops down-left.
# Tested for Godot 4.x API.

var _particles: GPUParticles2D
var _mat: ParticleProcessMaterial

const TOP_MARGIN := 8.0
const VISIBILITY_PAD := 1.2

func _ready() -> void:
	# --- Particles node -------------------------------------------------------
	_particles = GPUParticles2D.new()
	_particles.z_index = -100
	_particles.local_coords = false                 # screen-space feel
	_particles.amount = 1200
	_particles.lifetime = 1.6
	_particles.one_shot = false
	_particles.preprocess = 0.25                    # start with some already on-screen
	_particles.fixed_fps = 0                        # full framerate
	_particles.interpolate = true

	# TRAILS = thin lines (no textures -> no artifacts)
	_particles.trail_enabled = true
	_particles.trail_lifetime = 0.10                # short streak
	_particles.trail_sections = 3                   # few segments = straighter line
	_particles.trail_section_subdivisions = 0
	# Solid black trail (fade out to transparent)
	

	# Slight taper can look nice; keep subtle for minimalism
	var size_curve := Curve.new()
	size_curve.add_point(Vector2(0.0, 1.0))
	size_curve.add_point(Vector2(1.0, 0.6))
	var size_tex := CurveTexture.new()
	size_tex.curve = size_curve
	_particles.trail_size_modifier = size_tex


	# --- Process/material (motion & emission) --------------------------------
	_mat = ParticleProcessMaterial.new()
	_mat.color = Color.BLACK
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 1))
	grad.set_color(1, Color(0, 0, 0, 0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = grad
	_particles.trail_color_modifier = grad_tex
	# Direction: down-left (normalize to keep spread = 0 clean)
	_mat.direction = Vector3(-1, 1, 0).normalized()
	_mat.spread = 0.0                               # no angular spread (clean)
	# Accelerate along same diagonal for a nice glide
	_mat.gravity = Vector3(-750, 750, 0)            # tune to taste
	_mat.initial_velocity_min = 260.0
	_mat.initial_velocity_max = 360.0
	# No rotation or angular noise
	_mat.angular_velocity_min = 0.0
	_mat.angular_velocity_max = 0.0
	# Uniform “thickness” (trail handles visual size)
	_mat.scale_min = 1.0
	_mat.scale_max = 1.0

	# Emit along the top edge across full width (very thin box)
	_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	_update_emission_shape()

	_particles.process_material = _mat
	add_child(_particles)

	# Place the emitter at the top margin (y), centered (x). local_coords=false -> acts as screen-space.
	var vp := get_viewport_rect()
	_particles.position = Vector2(vp.size.x * 0.5, TOP_MARGIN)
	_update_visibility_rect()

	_particles.emitting = true


func _notification(what: int) -> void:
	# Keep things correct if the window/view resizes.
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_update_emission_shape()
		_update_visibility_rect()
		var vp := get_viewport_rect()
		_particles.position = Vector2(vp.size.x * 0.5, TOP_MARGIN)


func _update_emission_shape() -> void:
	var vp := get_viewport_rect()
	# emission_box_extents are half-size. We want full width, almost zero height.
	_mat.emission_box_extents = Vector3(vp.size.x * 0.5, 1.0, 0.0)


func _update_visibility_rect() -> void:
	var vp := get_viewport_rect()
	_particles.visibility_rect = Rect2(
		Vector2.ZERO,
		vp.size * VISIBILITY_PAD
	)
