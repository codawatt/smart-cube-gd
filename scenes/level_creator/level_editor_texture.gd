extends TextureRect

@export var map_layer: TileMapLayer
@export var map_viewport: SubViewport

# Tile to paint
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i(0, 0)
@export var alternative_tile: int = 0

func _ready() -> void:
	print("hi")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture = map_viewport.get_texture()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		print("click")
		_paint_at_mouse()

func _paint_at_mouse() -> void:
	var cell := _get_cell_under_mouse()
	print("Painting at cell: ", cell)
	if cell.x == -1: # invalid / outside
		return

	map_layer.set_cell(
		cell,
		source_id,
		atlas_coords,
		alternative_tile
	)


func _get_cell_under_mouse() -> Vector2i:
	# 1) Mouse position inside this TextureRect
	var local_pos: Vector2 = get_local_mouse_position()

	# Outside the rect → ignore
	if local_pos.x < 0 or local_pos.y < 0 \
	or local_pos.x > size.x or local_pos.y > size.y:
		return Vector2i(-1, -1)

	# 2) UV in 0..1 inside the TextureRect
	var uv: Vector2 = local_pos / size

	# 3) Position in SubViewport pixels
	var vp_size: Vector2 = Vector2(map_viewport.size)
	var viewport_pos: Vector2 = uv * vp_size

	# 4) Viewport pixels → world using canvas transform (no Camera2D)
	var canvas_xform: Transform2D = map_layer.get_viewport().canvas_transform
	var world_pos: Vector2 = canvas_xform.affine_inverse() * viewport_pos

	# 5) World → TileMapLayer local
	var local_in_layer: Vector2 = map_layer.to_local(world_pos)

	# 6) Local → tile cell
	var cell: Vector2i = map_layer.local_to_map(local_in_layer)
	return cell
