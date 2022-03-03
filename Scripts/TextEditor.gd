extends TextEdit

var lang: String # For syntax highlighting
var saved: bool = true # State of file
var file_path: String # For saving file again without save dialog
var file_name: String # Current file name
var indent_with: String = '\t' # Indent with Tabs is default
var completions: Array # List of completions
var functions: Array

func _ready() -> void:
	grab_focus()
	self.get_font("font").size = Settings.data['font_size'] # Set font size
	apply_colors()
	find_functions(text)
	parse_text(text)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		autocomplete_input_handler()

func apply_colors() -> void: # Apply syntax highlighting
	add_color_region("'", "'", Colors.prn_color)
	add_color_region('"', '"', Colors.prn_color)
	if lang in Syntax.languages:
		for keyword in Syntax.languages[lang]['keywords']:
			add_keyword_color(keyword, Colors.kw_color)
		add_color_region(Syntax.languages[lang]['sl_comment'], '', Colors.cm_color, true)

#################### SAVING FILE ####################

func save_file(path: String) -> void:
	var f: File = File.new()
	var _err = f.open(path, File.WRITE)
	f.store_string(text)
	f.close()

func save(save_as: bool = false) -> void:
	if file_name == 'Untitled' or save_as: # Popup dialog if saving for the first time
		$SaveDialog.current_dir = Global.current_path
		$SaveDialog.popup_centered()
	elif !saved: # If saving again just save file without dialog popup
		save_file(file_path)

func _on_SaveDialog_file_selected(path: String) -> void:
	save_file(path)
	file_path = path # Update current path
	file_name = path.get_file() # Update file name
	var tabs: Tabs = get_node("../../Tabs")
	tabs.set_tab_title(tabs.current_tab, file_name) # Update tab name
	saved = true

#################### SMART FEATURES ####################

func _on_TextEditor_text_changed() -> void:
	saved = false # Set state to unsaved
	close_brackets()
	autoindent()
	find_completions()
	
func close_brackets() -> void: # Add matching symbols
	# Ignore theese
	if Input.is_action_just_pressed("Del")\
	or Input.is_action_just_pressed("Backspace")\
	or Input.is_action_just_pressed("ui_accept")\
	or Input.is_action_just_pressed("ui_focus_next")\
	or Input.is_action_just_pressed("Undo")\
	or Input.is_action_just_pressed("Redo"): return
	
	var line = get_line(cursor_get_line()) # Get current line
	# Get charachter before cursor
	var last_char: String = line[cursor_get_column() - 1] if line else ''
	# Match symbols
	for symbol in Syntax.start_symbols:
		if last_char == symbol:
			insert_text_at_cursor(Syntax.end_symbols[Syntax.start_symbols.find(symbol)])
			cursor_set_column(cursor_get_column() - 1) # Move cursor back

func autoindent() -> void: # Insert tabs automatically
	if Input.is_action_just_pressed("Enter"): # Activate when enter pressed
		var prev_line: String = get_line(cursor_get_line() - 1) # Get previous line
		if prev_line and prev_line[-1] == ':': # If line ends with ":" indent next line
			insert_text_at_cursor(indent_with)

#################### AUTOCOMPLETION ####################

func find_completions() -> void: # Takes words from completions list and put it in popup window
	$Completions.visible = false
	# Parse current line if TAB or SPACE clicked
	if Input.is_action_just_pressed("ui_focus_next")\
	or Input.is_action_just_pressed("ui_select"):
		find_functions(get_line(cursor_get_line()))
		parse_text(get_line(cursor_get_line()))
		return
	# Ignore theese
	if Input.is_action_just_pressed("Del")\
	or Input.is_action_just_pressed("Backspace")\
	or Input.is_action_just_pressed("Undo")\
	or Input.is_action_just_pressed("Redo"): return
	var last_word: String = get_last_word()
	if last_word.length() < 2: return # Treshold for activation is 2 symbols
	$Completions.clear() # Clear old completions
	var longest_word: int = 0 # Need for dynamic popup width
	if !last_word in functions: # Prevent unneded completions
		for word in functions: # Add functions to completion list
			if word.begins_with(last_word):
				$Completions.add_item(word + '()')
				longest_word = word.length() + 1 if word.length() > longest_word else longest_word
	for word in completions: # Add words to completion list
		if word.begins_with(last_word):
			$Completions.add_item(word)
			longest_word = word.length() + 1 if word.length() > longest_word else longest_word
	show_completions(longest_word)

func show_completions(longest_word: int) -> void:
	if $Completions.get_item_count() == 0: return # If list not empty - create popup
	var line_width: float = get_line_width(cursor_get_line())
	var line_length: float = get_line(cursor_get_line()).length()
	var popup_width: float = line_width / line_length * longest_word + 10
	var popup_height: int = get_line_height() * $Completions.get_item_count()
	$Completions.rect_position = get_cursor_position() # Set popup to cursor position
	$Completions.rect_size = Vector2(popup_width, popup_height) # Set popup size
	$Completions.select(0) # Select first element
	$Completions.visible = true # Show popup

func autocomplete_input_handler() -> void:
	if !$Completions.visible: return
	var selected_item: int = $Completions.get_selected_items()[0]
	# If TAB is pressed - paste selected word from completion list
	if Input.is_action_just_pressed("ui_focus_next"):
		var last_word: String = get_last_word()
		var selected_word: String = $Completions.get_item_text(selected_item)
		insert_text_at_cursor(selected_word.trim_prefix(last_word))
		if selected_word[-1] == ')': # Move cursor inside brackets for functions
			cursor_set_column(cursor_get_column() - 1)
		get_tree().set_input_as_handled() # Ignore defaul keys behavior
	# Choose next suggestion
	if Input.is_action_pressed("ui_down"):
		if selected_item + 1 < $Completions.get_item_count():
			$Completions.select(selected_item + 1)
		get_tree().set_input_as_handled() # Ignore defaul keys behavior
	# Choose previous suggestion
	if Input.is_action_pressed("ui_up"):
		if selected_item - 1 >= 0:
			$Completions.select(selected_item - 1)
		get_tree().set_input_as_handled() # Ignore defaul keys behavior

func get_cursor_position() -> Vector2:
	var line_number: int = cursor_get_line()
	var column_number: int = cursor_get_column()
	var line_height: int = get_line_height()
	var line_width: float = get_line_width(cursor_get_line())
	var line_length: float = get_line(cursor_get_line()).length()
	var gutter: int = get_total_gutter_width()
	var y_offcet: int = 1 # 0 - top of the line, 1 - bottom of the line
	var ypos: float = (line_number - scroll_vertical + y_offcet) * line_height
	var xpos: float
	if line_length > 0:
		var width_unit: float = line_width / line_length
		xpos = gutter + column_number * width_unit - scroll_horizontal
	return Vector2(xpos, ypos)

#################### PARSING TEXT ####################

func find_functions(text_to_parse: String):
	var regex = RegEx.new()
	regex.compile("\\w+(\\()")
	for result in regex.search_all(text_to_parse):
		if result.get_string().length() > 2\
		and !result.get_string().trim_suffix('(') in functions:
			functions.append(result.get_string().trim_suffix('('))

func parse_text(text_to_parse: String) -> void: # Find words in string using RegEx
	var regex = RegEx.new()
	regex.compile("\\w+")
	for result in regex.search_all(text_to_parse):
		if result.get_string().length() > 2\
		and !result.get_string() in completions\
		and !result.get_string() in functions:
			completions.append(result.get_string()) # Add word if it's bigger than 2 letters

func get_last_word() -> String:
	var regex: RegEx = RegEx.new()
	var _err = regex.compile("\\w+")
	var results: Array = []
	for result in regex.search_all(get_line(cursor_get_line())):
		results.append(result.get_string())
	return results[-1] if results else ''

#################### CLOSING ####################

func close_tab() -> void:
	var tabs: Tabs = get_node("../../../Tabs")
	if Global.tabs.size() >= 1: # Switch to last opened tab
		tabs.current_tab = Global.tabs.size() - 1
	tabs.remove_tab(tabs.current_tab)
	Global.tabs.erase(self.name) # Delete tab from tabs list
	Settings.data['last_files'].erase(file_path)
	Settings.set_data(Settings.data)
	queue_free() # Destroy self
	
func close() -> void:
	if !saved:
		$ConfirmationDialog.popup_centered()
	else:
		close_tab()

func _on_ConfirmationDialog_confirmed():
	close_tab()
