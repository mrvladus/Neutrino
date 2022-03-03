extends Control

onready var text_scene: PackedScene = preload("res://TextEditor.tscn")
onready var Filedialog: FileDialog = $FileDialog
onready var	Editors: Control = $Split/Editors
onready var Sidebar: Tree = $Split/Sidebar
onready var tabs: Tabs = $Tabs

var index: int = 0 # Unique id for each tab

func _ready() -> void:
	open_last_files()

func create_new_file(file_name: String, content: String, extension: String, path: String = '') -> void:
	var editor: TextEdit = text_scene.instance()
	editor.name = str(index) # Apply unique id
	editor.lang = extension # For syntax highlighting
	editor.text = content # Content of the opened file
	editor.file_name = file_name
	editor.file_path = path
	if path != '' and !path in Settings.data['last_files']:
		Settings.data['last_files'].append(path) # Add file path to last files
	Global.tabs.append(editor.name) # Add tab to global tab list
	Editors.add_child(editor) # Create new text editor and add it to scene
	tabs.add_tab(file_name) # Name of tab
	tabs.current_tab = tabs.get_tab_count() - 1 # Focus to the new tab
	Editors.get_node(Global.tabs[tabs.current_tab]).grab_focus() # Put cursor in text the editor
	index += 1 # Increase tab id

func open_file(path: String):
	var file_name: String = path.get_file()
	var extension: String = path.get_extension()
	var f: File = File.new()
	var _err = f.open(path, File.READ)
	var content: String = f.get_as_text()
	f.close()
	create_new_file(file_name, content, extension, path)
	Global.current_path = path.get_base_dir() # Set current path for opening new files from the same folder

func open_last_files() -> void: # Open previously opened files
	var last_files = Settings.data['last_files']
	if last_files != []:
		for file in last_files:
			open_file(file)

########## SIGNALS HANDLERS ##########

func _on_Tabs_tab_changed(tab: int) -> void:
	# Move selected tab to the top
	Editors.move_child(Editors.get_node(Global.tabs[tab]), Editors.get_child_count())
	# Put cursor in text the editor
	Editors.get_node(Global.tabs[tab]).grab_focus()

func _on_Tabs_tab_close(tab: int) -> void:
	Editors.get_node(Global.tabs[tab]).close() # Close editor

func _on_FileDialog_file_selected(path: String) -> void:
	open_file(path)

func _on_FileDialog_dir_selected(dir: String) -> void:
	Global.current_path = dir # Set global path to selected dir
	Sidebar.fill_tree() # Fill sidebar
	Sidebar.visible = true # Set it visible
	Settings.data['sidebar'] = true # Change settings

func _on_Main_resized() -> void:
	Settings.data['window_height'] = OS.window_size.y
	Settings.data['window_width'] = OS.window_size.x
