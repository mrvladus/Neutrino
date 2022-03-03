extends Node

var data: Dictionary = {
	'ver' : '0.1',
	'window_height' : 600,
	'window_width' : 1024,
	'font_size' : 16,
	'effects' : true,
	'sidebar' : false,
	'last_files' : [],
	'current_path' : ''
} setget set_data, get_data # Call save_setting when data changes

func _ready() -> void:
	init_settings()

func get_data() -> Dictionary:
	return data

func set_data(_new_data) -> void:
	var f = File.new()
	f.open('user://settings', File.WRITE)
	f.store_line(to_json(data))
	f.close()

func init_settings() -> void:
	var dir = Directory.new()
	var _err = dir.open('user://')
	if dir.file_exists('user://settings'): # Load settings if file exists
		var f: File = File.new()
		var _err1 = f.open('user://settings', File.READ)
		data = parse_json(f.get_line())
		f.close()
	else: # Create new settings file
		var f = File.new()
		var _err1 = f.open('user://settings', File.WRITE)
		f.store_line(to_json(data))
		f.close()
