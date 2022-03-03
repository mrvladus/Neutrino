extends MenuButton

onready var menu = get_popup()
onready var main = get_parent()
onready var Filedialog = main.get_node("FileDialog")
onready var Editors = main.get_node("Split/Editors")
onready var tabs =  main.get_node("Tabs")
onready var Sidebar = main.get_node("Split/Sidebar")

func _ready():
	set_hotkeys()

func set_hotkeys() -> void:
	var _err = menu.connect("id_pressed", self, "_on_item_pressed")
	menu.set_item_accelerator(0, KEY_N | KEY_MASK_CTRL) # New
	menu.set_item_accelerator(1, KEY_O | KEY_MASK_CTRL) # Open file
	menu.set_item_accelerator(2, KEY_O | KEY_MASK_CTRL | KEY_MASK_SHIFT) # Open foder
	menu.set_item_accelerator(3, KEY_S | KEY_MASK_CTRL) # Save
	menu.set_item_accelerator(4, KEY_S | KEY_MASK_CTRL | KEY_MASK_SHIFT) # Save as
	menu.set_item_accelerator(5, KEY_B | KEY_MASK_CTRL) # Toggle sidebar
	menu.set_item_accelerator(7, KEY_EQUAL | KEY_MASK_CTRL) # Increase font size
	menu.set_item_accelerator(8, KEY_MINUS| KEY_MASK_CTRL) # Decrease font sizev

func _on_item_pressed(id) -> void:
	var item = menu.get_item_text(id)
	match item:
		'New':
			main.create_new_file('Untitled', '', '') # Create empty file
		'Open file':
			Filedialog.mode = FileDialog.MODE_OPEN_FILE
			Filedialog.current_dir = Global.current_path # Set current dir to user's home
			Filedialog.popup_centered() # Show file dialog
		'Open folder':
			Filedialog.mode = FileDialog.MODE_OPEN_DIR
			Filedialog.current_dir = Global.current_path
			Filedialog.popup_centered() # Show file dialog
		'Save':
			if Global.tabs.size() > 0: # If tabs exist call it's save function
				Editors.get_node(Global.tabs[tabs.current_tab]).save()
		'Save as':
			if Global.tabs.size() > 0: # If tabs exist call it's save function
				Editors.get_node(Global.tabs[tabs.current_tab]).save(true)
		'Toggle sidebar':
			Sidebar.visible = !Sidebar.visible
			Settings.data['sidebar'] = Sidebar.visible
		'Increase font size':
			if Global.tabs.size() > 0:
				var font = Editors.get_node(Global.tabs[tabs.current_tab]).get_font('font')
				font.size += 2
				Settings.data['font_size'] = font.size
		'Decrease font size':
			if Global.tabs.size() > 0:
				if Editors.get_node(Global.tabs[tabs.current_tab]).get_font('font').size >= 12:
					var font = Editors.get_node(Global.tabs[tabs.current_tab]).get_font('font')
					font.size -= 2
					Settings.data['font_size'] = font.size
