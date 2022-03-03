extends Node

# ---------- GLOBAL VARIABLES ---------- #
var tabs: Array = [] # Stores tab id's
var sidebar: bool = false # State of the sidebar
var current_path: String setget path_changed # Stores current working folder

func _ready() -> void:
	set_window_size()
	set_current_path()

func set_current_path() -> void: 
	current_path = Settings.data['current_path']
	if current_path != '': return
	# Set current path to home folder
	if OS.get_name() == 'X11':
		current_path = OS.get_environment('HOME')
	elif OS.get_name() == 'Windows':
		current_path = OS.get_environment('%HOMEPATH%')

func path_changed(new_path):
	current_path = new_path
	Settings.data['current_path'] = new_path

func set_window_size() -> void:
	OS.min_window_size = Vector2(400, 350)
	OS.window_size = Vector2(Settings.data['window_width'], Settings.data['window_height'])
	
