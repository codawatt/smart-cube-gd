# LevelData.gd
@tool
extends Resource
class_name LevelData

# ---- Grid bounds (customizable) ----
@export_range(1, 256, 1) var width:  int = 16
@export_range(1, 256, 1) var height: int = 9

# ---- Backing storage (kept private) ----
@export var _stage_numbers:   Dictionary[Vector2i, int]       = {}
@export var _stage_platforms: Dictionary[Vector2i, int]       = {} # use your enum type for value
@export var _stage_coins:     Dictionary[Vector2i, Vector2i]  = {}
@export var _stage_powerups:  Dictionary[Vector2i, int]     = {}
@export var _player_start:    Vector2i                        = Vector2i(0, 0)

# ---- Public properties w/ validators (so Inspector edits are guarded) ----
var stage_numbers: Dictionary[Vector2i, int]:
	set(v):
		_stage_numbers = {}
		for pos: Vector2i in v.keys():
			_guard_pos(pos, "stage_numbers")
			_guard_free(pos, "stage_numbers")
			_stage_numbers[pos] = v[pos]
	get:
		return _stage_numbers

var stage_platforms: Dictionary[Vector2i, int]:
	set(v):
		_stage_platforms = {}
		for pos: Vector2i in v.keys():
			_guard_pos(pos, "stage_platforms")
			_guard_free(pos, "stage_platforms")
			_stage_platforms[pos] = v[pos]
	get:
		return _stage_platforms

var stage_coins: Dictionary[Vector2i, Vector2i]:
	set(v):
		_stage_coins = {}
		for pos: Vector2i in v.keys():
			_guard_pos(pos, "stage_coins")
			_guard_free(pos, "stage_coins")
			# also keep coin target in-bounds
			_guard_pos(v[pos], "stage_coins.target")
			_guard_number_ref(v[pos], "stage_coins.target")
			_stage_coins[pos] = v[pos]
	get:
		return _stage_coins

var stage_powerups: Dictionary[Vector2i,int]:
	set(v):
		_stage_powerups = {}
		for pos: Vector2i in v.keys():
			_guard_pos(pos, "stage_powerups")
			_guard_free(pos, "stage_powerups")
			_stage_powerups[pos] = v[pos]
	get:
		return _stage_powerups

var player_start: Vector2i:
	set(v):
		_guard_pos(v, "player_start")
		_guard_free(v, "player_start")
		_player_start = v
	get:
		return _player_start

# ---- Public API (safe helpers to mutate contents) ----
func add_number(pos: Vector2i, value: int) -> void:
	_guard_pos(pos, "stage_numbers")
	_guard_free(pos, "stage_numbers")
	_stage_numbers[pos] = value

func add_platform(pos: Vector2i, platform_type: int) -> void:
	_guard_pos(pos, "stage_platforms")
	_guard_free(pos, "stage_platforms")
	_stage_platforms[pos] = platform_type

func add_coin(pos: Vector2i, target: Vector2i) -> void:
	_guard_pos(pos, "stage_coins")
	_guard_free(pos, "stage_coins")
	_guard_pos(target, "stage_coins.target")
	_guard_number_ref(target, "stage_coins.target")
	_stage_coins[pos] = target

func add_powerup(pos: Vector2i, val:int) -> void:
	_guard_pos(pos, "stage_powerups")
	_guard_free(pos, "stage_powerups")
	_stage_powerups[pos] = val

func remove_at(pos: Vector2i) -> void:
	# removes from whichever bucket contains it
	_stage_numbers.erase(pos)
	_stage_platforms.erase(pos)
	_stage_coins.erase(pos)
	_stage_powerups.erase(pos)

# ---- Validation / diagnostics ----
func validate() -> void:
	# Throws if anything is out-of-bounds or overlapping.
	# Call this in tooling (e.g., from a button) or tests.
	for pos in _iter_all_positions():
		_guard_pos(pos, "validate")
	# Check overlaps by counting occupants
	var counts := {}
	for pos in _iter_all_positions():
		counts[pos] = (counts.get(pos, 0) as int) + 1
	for pos in counts.keys():
		if counts[pos] > 1:
			_push_err("Overlap at %s (count=%d)" % [pos, counts[pos]])
	# Coin targets also must be in-bounds (already checked in setters/adders)
	# No exception here; _guard_pos already raised if invalid.

# ---- Internal guards ----
func _guard_pos(p: Vector2i, who: String) -> void:
	if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
		_push_err("%s: position %s out of bounds (0 ≤ x < %d, 0 ≤ y < %d)" % [who, p, width, height])

func _guard_free(p: Vector2i, who: String) -> void:
	if _occupied(p):
		_push_err("%s: position %s already occupied" % [who, p])
func _guard_number_ref(p: Vector2i, who: String) -> void:
	# Coin targets must reference an existing stage_numbers cell
	if not _stage_numbers.has(p):
		_push_err("%s: %s does not reference an existing stage_numbers key" % [who, p])
func _occupied(p: Vector2i) -> bool:
	return _stage_numbers.has(p) \
		or _stage_platforms.has(p) \
		or _stage_coins.has(p) \
		or (_stage_powerups.has(p)) \
		or (_player_start == p)

func _iter_all_positions() -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	for pos in _stage_numbers.keys(): list.append(pos)
	for pos in _stage_platforms.keys(): list.append(pos)
	for pos in _stage_coins.keys(): list.append(pos)
	for pos in _stage_powerups: list.append(pos)
	list.append(_player_start)
	return list

func _push_err(msg: String) -> void:
	# Use both editor & runtime channels for visibility
	push_error(msg)
	assert(false, msg)
