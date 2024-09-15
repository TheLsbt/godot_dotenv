@tool
extends EditorPlugin

const SyntaxHighlighting = preload("res://addons/dotenv/complements/syntax_highlighting.gd")
const SETTING_PATH = 'docks/filesystem/textfile_extensions'

var original_setting = ''
var syntax_highlighting: SyntaxHighlighting


func _enter_tree() -> void:
	# To recognise .env file we need to modify a option in the editor settings
	var settings = EditorInterface.get_editor_settings()
	if not (settings.get_setting(SETTING_PATH) as String).contains('env'):
		settings.set_setting(SETTING_PATH, original_setting + ',env')

	syntax_highlighting = SyntaxHighlighting.new()
	syntax_highlighting.onload()


func _exit_tree() -> void:
	if syntax_highlighting:
		syntax_highlighting.unload()
