extends Tree

onready var main: Control = get_parent().get_parent()

var folder_icon: Texture = preload("res://icons/folder.png")
var file_icon: Texture = preload("res://icons/file.png")

func _ready():
	visible = Settings.data['sidebar']
	fill_tree(true)

func fill_tree(clear: bool = false, path: String = Global.current_path, root_dir: TreeItem = null):
	if clear:
		clear() # Clear tree
	var dir: Directory = Directory.new()
	var _err = dir.open(path) # Open folder
	_err = dir.list_dir_begin(true)
	var file_name: String = dir.get_next()
	var root: TreeItem
	if root_dir == null:
		root = create_item()
		root.set_text(0, path.get_file())
		root.set_icon(0, folder_icon)
	else:
		root = root_dir
	while file_name != '':
		if dir.current_is_dir():
			var element: TreeItem = create_item(root)
			element.set_text(0, file_name)
			element.set_icon(0, folder_icon)
			element.set_collapsed(true)
			fill_tree(false, path + '/' + file_name, element)
		file_name = dir.get_next()
	_err = dir.list_dir_begin(true)
	file_name = dir.get_next()
	while file_name != '':
		if dir.file_exists(file_name):
			var element: TreeItem = create_item(root)
			element.set_text(0, file_name)
			element.set_icon(0, file_icon)
		file_name = dir.get_next()

func get_selected_path(): # Get full path of the tree item
	var base_path: PoolStringArray = [Global.current_path]
	var path: Array = []
	var item: TreeItem = get_selected()
	while item.get_parent() != null:
		path.push_front(item.get_text(0))
		item = item.get_parent()
	base_path.append_array(path)
	return base_path.join("/")

########## SIGNALS HANDLERS ##########

func _on_Sidebar_item_activated():
	var dir: Directory = Directory.new()
	var path: String = get_selected_path()
	if dir.file_exists(path):
		main.open_file(path)

func _on_Sidebar_item_rmb_selected(position): # Right click menu
	$SidebarMenu.set_position(position)
	$SidebarMenu.popup()

func _on_SidebarMenu_id_pressed(id):
	var dir: Directory = Directory.new()
	var path = get_selected_path()
	var text = $SidebarMenu.get_item_text(id)
	match text:
		'Delete':
			var _err = dir.remove(path)
			fill_tree(true)
		'Rename':
			$Dialog.window_title = 'Rename'
			$Dialog.popup_centered()
			$Dialog/Text.grab_focus()
		'Show folder':
			if dir.file_exists(path):
				var _err = OS.shell_open(path.get_base_dir())
			elif dir.dir_exists(path):
				var _err = OS.shell_open(path)
		'New folder':
			$Dialog.window_title = 'Create folder'
			$Dialog.popup_centered()
			$Dialog/Text.grab_focus()

func _on_Text_text_entered(new_text):
	if new_text == '': return
	var dir: Directory = Directory.new()
	var path: String = get_selected_path()
	if $Dialog.window_title == 'Rename':
		var _err = dir.rename(path, path.get_base_dir() + '/' + new_text)
		$Dialog/Text.text = ''
		$Dialog.hide()
		get_selected().set_text(0, new_text)
	elif $Dialog.window_title == 'Create folder':
		if dir.file_exists(path):
			path = path.get_base_dir()
		var _err = dir.make_dir_recursive(path + '/' + new_text)
		$Dialog/Text.text = ''
		$Dialog.hide()
		fill_tree(true)
