@tool
extends EditorPlugin

const setting_path = 'docks/filesystem/textfile_extensions'

# Roadmap:
# Syntax highlighting

var original_setting = ''
var env_highlighter = preload("res://addons/dotenv/env_highlighter.gd").new()
var update_timer := Timer.new()


func _enter_tree() -> void:
	update_timer.wait_time = 3
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)

	if EditorInterface.get_script_editor().visible:
		update_timer.start()
	EditorInterface.get_script_editor().visibility_changed.connect(_on_script_editor_visibility_changed)

	var settings = EditorInterface.get_editor_settings()
	original_setting = settings.get_setting(setting_path)
	settings.set_setting(setting_path, original_setting + ',env')


func _exit_tree() -> void:
	update_timer.queue_free()
	deregister_env_syntax_highlighters()

	var settings = EditorInterface.get_editor_settings()
	settings.set_setting(setting_path, original_setting)


func _on_script_editor_visibility_changed() -> void:
	if EditorInterface.get_script_editor().visible:
		update_timer.start()
	else:
		update_timer.stop()


func _on_update_timer_timeout() -> void:
	var script_editor = EditorInterface.get_script_editor()
	var c_editor = script_editor.get_current_editor()

	if is_instance_valid(c_editor) and c_editor.get_class() == 'TextEditor':
		await get_tree().process_frame
		var filepath = str(c_editor.get('metadata/_edit_res_path'))
		if filepath.ends_with('.env'):
			if c_editor.get_base_editor().get('syntax_highlighter') != env_highlighter:
				c_editor.get_base_editor().set('syntax_highlighter', env_highlighter)
				print('update')
	return

	#if current_editor.get_class() == 'TextEditor':
		#print(current_editor.get('metadata/_edit_res_path'))
		#if (current_editor.get('metadata/_edit_res_path') as String).get_extension() == 'env':
			##if (current_editor as CodeEdit).syntax_highlighter == null:
				#(current_editor as CodeEdit).syntax_highlighter = env_highlighter
				#print('udpate')


func deregister_env_syntax_highlighters() -> void:
	var script_editor = EditorInterface.get_script_editor()
	for i in script_editor.get_open_script_editors():
		if i.get_class() == 'TextEditor':
			var script_path: String = i.get('metadata/_edit_res_path')
			if script_path.get_extension() == 'env':
				(i.get_base_editor() as CodeEdit).syntax_highlighter = null
