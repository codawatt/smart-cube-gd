@tool
class_name LevelLoader
extends Node

signal level_load_started
signal level_loaded
signal level_ready

@export var level_container : Node
@export var level_loading_screen : LoadingScreen
@export var level_scene: PackedScene
@export var level_instance: Level = null
@export_group("Debugging")
@export var current_level : Node

var is_loading : bool = false

func _attach_level_scene(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance
	
func _attach_level(level_data : LevelData, level_path: String): 
	assert(level_container != null, "level_container is null")
	assert(level_scene != null, "level_scene is null")
	#if not level_instance:
	level_instance = level_scene.instantiate()
	# Expect the scene's root to expose `level_data` (your Level.gd does).
	# Helper: check if a property exists on the instance.
	#level_instance._clean_map_elements()
	# Assign exports if present.
	if _has_prop(level_instance, "level_data"):
		level_instance.set("level_data", level_data)
	else:
		push_error("Level scene has no `level_data` export to assign!")
	if _has_prop(level_instance, "level_path"):
		level_instance.set("level_path", level_path)
	level_container.call_deferred("add_child", level_instance)
	return level_instance

func _has_prop(obj: Object, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if typeof(p) == TYPE_DICTIONARY and p.has("name") and p.name == prop_name:
			return true
	return false
func load_level_scene(level_path : String):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	is_loading = true
	SceneLoader.load_scene(level_path, true)
	if level_loading_screen:
		level_loading_screen.reset()
	level_load_started.emit()
	await SceneLoader.scene_loaded
	is_loading = false
	current_level = _attach_level_scene(SceneLoader.get_resource())
	if level_loading_screen:
		level_loading_screen.close()
	level_loaded.emit()
	await current_level.ready
	level_ready.emit()
	
func load_level(level_path : String):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	is_loading = true
	if level_loading_screen:
		level_loading_screen.reset()
	level_load_started.emit()
	# Load LevelData (synchronously for simplicity; swap with interactive loader if needed)
	var data : Resource = ResourceLoader.load(level_path)
	assert(data != null, "Failed to load LevelData resource at: %s" % level_path)
	assert(data is LevelData, "Resource at %s is not a LevelData!" % level_path)
	is_loading = false
	current_level = _attach_level(data, level_path)
	if level_loading_screen:
		level_loading_screen.close()
	level_loaded.emit()
	await current_level.ready
	level_ready.emit()
