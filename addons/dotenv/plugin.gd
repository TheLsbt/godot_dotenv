@tool
extends EditorPlugin

const Dotenv = preload("res://addons/dotenv/dotenv.gd")
const SyntaxHighlighting = preload("res://addons/dotenv/complements/syntax_highlighting.gd")
const SETTING_PATH = 'docks/filesystem/textfile_extensions'

var original_setting = ''
var syntax_highlighting: SyntaxHighlighting


func _enter_tree() -> void:
	# To recognise .env file we need to modify a option in the editor settings
	var settings = EditorInterface.get_editor_settings()
	original_setting = settings.get_setting(SETTING_PATH).strip_edges()
	if not original_setting.contains("env"):
		var adding = "env"
		if original_setting:
			adding = ","+adding
		settings.set_setting(SETTING_PATH, original_setting + adding)

	syntax_highlighting = SyntaxHighlighting.new()
	syntax_highlighting.onload()


func _exit_tree() -> void:
	if syntax_highlighting:
		syntax_highlighting.unload()
