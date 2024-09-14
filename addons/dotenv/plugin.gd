@tool
extends EditorPlugin

const setting_path = 'docks/filesystem/textfile_extensions'

# Roadmap:
# Syntax highlighting
# Complements system
#	Load complements
# Add Settings for plugin

# Code parsing and error throwing in the editor


var original_setting = ''
var active_complements = []


func _enter_tree() -> void:
	# We do this to recognise .env files
	# Would like if there is another way that doesnt modifying the editor settings
	var settings = EditorInterface.get_editor_settings()
	original_setting = settings.get_setting(setting_path)
	settings.set_setting(setting_path, original_setting + ',env')

	load_complements()


func _exit_tree() -> void:
	var settings = EditorInterface.get_editor_settings()
	settings.set_setting(setting_path, original_setting)

	unload_complements()


func load_complements() -> void:
	var script = get_script()
	var path = ''

	if script is Script:
		path = script.resource_path.get_base_dir() + '/complements'

	if not DirAccess.dir_exists_absolute(path):
		printerr('Failed to find the complements directory')
		return

	var files = DirAccess.get_files_at(path)
	for file in files:
		# NOTE: There is no type checking for a complement so technically any script can be one
		# but i might add this in the future, to catch errors
		var complement = load(path + '/' + file).new()
		complement.onload()
		print('Loaded ', complement._get_complement_name())
		active_complements.append(complement)


func unload_complements() -> void:
	for complement in active_complements:
		complement.unload()
