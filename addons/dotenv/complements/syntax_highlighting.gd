@tool
extends EditorScript

# The amount of time it takes chack if we need to add syntax highlighting to the editor
const SYNTAX_REFRESH_TIMER := 1.5

var update_timer := Timer.new()
var env_highlighter := EnvHighlighter.new()


func get_class() -> String:
	return 'dotenv_complement'


func onload() -> void:
	update_timer.wait_time = SYNTAX_REFRESH_TIMER
	update_timer.name = 'EnvSyntaxRefreshTimer'
	update_timer.timeout.connect(try_syntax_highlight)

	var script_editor := EditorInterface.get_script_editor()
	script_editor.add_child(update_timer)

	# We only want the timer to update when we are looking at scripts
	script_editor.visibility_changed.connect(
		func():
			if script_editor.is_visible():
				update_timer.start()
			else:
				update_timer.stop()
	)

	# Start the timer now if we are looking at scripts
	if script_editor.is_visible():
		update_timer.start()



func unload() -> void:
	update_timer.queue_free()
	reset_syntax_highlighting()


func _get_complement_name() -> String:
	return 'SyntaxHighlighting'

# Tries to add syntax highlighting to the currently open script editor
func try_syntax_highlight() -> void:
	var script_editor := EditorInterface.get_script_editor()
	var editor = script_editor.get_current_editor()

	if is_instance_valid(editor) and editor.get_class() == 'TextEditor':
		var filepath: String = editor.get('metadata/_edit_res_path')
		if filepath.ends_with('.env'):
			if editor.get_base_editor().get('syntax_highlighter') != env_highlighter:
				editor.get_base_editor().set('syntax_highlighter', env_highlighter)


func reset_syntax_highlighting() -> void:
	var script_editor := EditorInterface.get_script_editor()
	for editor: ScriptEditorBase in script_editor.get_open_script_editors():
		if editor.get_class() == 'TextEditor':
			var filepath: String = editor.get('metadata/_edit_res_path')
			if filepath.ends_with('.env'):
				# Although these editors are supposed to have a text syntax highlighting, it looks
				# the same as null
				editor.get_base_editor().syntax_highlighter = null


class EnvHighlighter extends EditorSyntaxHighlighter:
	# Color constants
	# TODO: Add these as settings
	const COMMENT_COLOR := Color(0.669, 0.669, 0.669)
	const KEY_COLOR := Color(0.628, 0.987, 0.716)
	const EQ_COLOR := Color(0.98, 0.678, 0.743)
	const VALUE_COLOR := Color(0.685, 0.818, 0.971)


	func _get_line_syntax_highlighting(line: int) -> Dictionary:
		var line_string := get_text_edit().get_line(line)

		var line_type := 'none'
		var end := 0

		var data = {}

		var found_key = false
		var in_value = false
		var start := 0

		for index in range(line_string.length()):
			var ch := line_string[index]

			if ch == ' ':
				continue

			elif ch == '#':
				data[index] = {'color': COMMENT_COLOR}
				break
			elif ch != '=':
				if not found_key:
					data[index] = {'color': KEY_COLOR}
					found_key = true
				elif in_value:
					data[index] = {'color': VALUE_COLOR}
			elif ch == '=':
				data[index] = {'color': EQ_COLOR}
				in_value = true


		return data
