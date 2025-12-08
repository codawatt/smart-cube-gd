@tool
extends Node
class_name FileLister

@warning_ignore("unused_private_class_variable")
@export var _refresh_files_action : bool = false :
	set(value):
		if value and Engine.is_editor_hint():
			_refresh_files()

@export var files : Array[String]

@export_dir var directories : Array[String] :
	set(value):
		directories = value
		_refresh_files()

@export_group("Constraints")
@export var search : String
@export var filter : String

@export_subgroup("Advanced Search")
@export var begins_with : String
@export var ends_with : String
@export var not_begins_with : String
@export var not_ends_with : String


func _refresh_files():
	if not is_inside_tree(): return
	files.clear()
	for directory in directories:
		var dir_access = DirAccess.open(directory)
		if dir_access:
			for file in dir_access.get_files():
				if (not search.is_empty()) and (not file.contains(search)):
					continue
				if (not filter.is_empty()) and (file.contains(filter)):
					continue
				if (not begins_with.is_empty()) and (not file.begins_with(begins_with)):
					continue
				if (not ends_with.is_empty()) and (not file.ends_with(ends_with)):
					continue
				if (not not_begins_with.is_empty()) and (file.begins_with(not_begins_with)):
					continue
				if (not not_ends_with.is_empty()) and (file.ends_with(not_ends_with)):
					continue
				files.append(directory + "/" + file)
