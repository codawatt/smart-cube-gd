@tool
extends Node
class_name SceneLister 

@export var files : Array[String]
@export_dir var directory_scenes : String :
	set(value):
		directory_scenes = value
		_refresh_files(".tres",directory_scenes)

func _refresh_files(suffix:String, directory:String):
	if not is_inside_tree() or directory.is_empty(): return
	var dir_access = DirAccess.open(directory)
	if dir_access:
		files.clear()
		for file in dir_access.get_files():
			if not file.ends_with(suffix):
				continue
			files.append(directory + "/" + file)
		files.sort_custom(func(a: String, b: String) -> bool:
			return a.naturalnocasecmp_to(b) < 0
		)
		
