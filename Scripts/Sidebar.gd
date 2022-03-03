extends Tree

# Get nodes
onready var main: Control = get_parent().get_parent()
# Load resourses
var folder_icon: Texture = preload("res://icons/open.png")
var file_icon: Texture = preload("res://icons/file.png")
var back_icon: Texture = preload("res://icons/back.png")

var dir: Directory = Directory.new()
var folders: Array = []
var files: Array  = []

func _ready():
	visible = Settings.data['sidebar']
	fill_tree()

func fill_tree() -> void:  # Call deffered from input handler!
	var _err = dir.open(Global.current_path)
	folders.clear()
	files.clear()
	clear()
	var _err1 = dir.list_dir_begin(true)
	var file_name: String = dir.get_next()
	while file_name != '':
		if dir.current_is_dir():
			folders.append(file_name)
		else:
			files.append(file_name)
		file_name = dir.get_next()
	var root: TreeItem = create_item()
	var back: TreeItem = create_item(root)
	back.set_text(0, Global.current_path.get_file())
	back.set_icon(0, back_icon)
	folders.sort()
	for folder in folders:
		var element: TreeItem = create_item(root)
		element.set_text(0, folder)
		element.set_icon(0, folder_icon)
	files.sort()
	for file in files:
		var element: TreeItem = create_item(root)
		element.set_text(0, file)
		element.set_icon(0, file_icon)

func _on_Tree_item_activated() -> void:
	var text: String = get_selected().get_text(0)
	if text == Global.current_path.get_file():
		Global.current_path = Global.current_path.get_base_dir()
		call_deferred('fill_tree')
		return
	var path: String = Global.current_path + '/' + text
	if dir.dir_exists(path):
		Global.current_path = path
		call_deferred('fill_tree')
	elif dir.file_exists(path):
		main.open_file(path)

func _on_Sidebar_item_rmb_selected(position): # Right click menu
	$SidebarMenu.set_position(position)
	$SidebarMenu.popup()

func _on_SidebarMenu_id_pressed(id):
	var text = $SidebarMenu.get_item_text(id)
	var path = Global.current_path + '/' + get_selected().get_text(0)
	match text:
		'Open':
			if dir.file_exists(path):
				main.open_file(path)
			elif dir.dir_exists(path):
				Global.current_path = path
				fill_tree()
		'Delete':
			if dir.file_exists(path):
				var _err = dir.remove(path)
				fill_tree()
			elif dir.dir_exists(path):
				var _err = dir.remove(path)
				fill_tree()
		'Rename':
			$Dialog.window_title = 'Rename'
			$Dialog.popup_centered()
			$Dialog/Text.grab_focus()
		'Show folder':
			if dir.file_exists(path): # Open current dir if file
				var _err = OS.shell_open(Global.current_path)
			elif dir.dir_exists(path): # Open dir if folder 
				var _err = OS.shell_open(path)
		'New folder':
			$Dialog.window_title = 'Create folder'
			$Dialog.popup_centered()
			$Dialog/Text.grab_focus()

func _on_RenameText_text_entered(new_text):
	if new_text == '': return
	if $Dialog.window_title == 'Rename':
		var _err = dir.rename(get_selected().get_text(0), new_text)
		$Dialog/Text.text = ''
		$Dialog.hide()
		fill_tree()
	elif $Dialog.window_title == 'Create folder':
		var _err = dir.make_dir_recursive(new_text)
		$Dialog/Text.text = ''
		$Dialog.hide()
		fill_tree()
