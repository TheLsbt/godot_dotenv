extends RefCounted
class_name Dotenv

## Loads files directly into the enviroment
## This is mostly for local develoment, use something like github secrets for production
## code.

enum ENV_STR_VALIDATION {
	SINGLE, DOUBLE, NO_QUOTE, NONE, FAILED, NON_MATCHING_QUOTE
}

const REGEX_PATTERN = '^(.*?) *= *(.*?)$'


# If the path is a file we dont check if it ends with .env but if we check through a directory we
# only pickup .env files.
static func load_(path: String, recursive := false, continue_in_release := false) -> void:
	# Check if the current path is a directory,
	var is_dir := path.get_extension().is_empty()

	if is_dir:
		var files = DirAccess.get_files_at(path)
		for file in files:
			if file.get_extension() == 'env':
				load_env_file(path + '/' + file, continue_in_release)

		if recursive:
			var directories = DirAccess.get_directories_at(path)
			for dir in directories:
				load_(path + '/' + dir, recursive, continue_in_release)
	else:
		load_env_file(path, continue_in_release)


# This loads a file directly, its better to use load_() because it has checks
static func load_env_file(path: String, continue_in_release: bool) -> void:
	# It isnt recommended to use env files in a production build, use github secrets
	if OS.has_feature('release') and not continue_in_release:
		return

	if not FileAccess.file_exists(path):
		printerr('Cannot find file at ', path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var open_error := file.get_open_error()
	if open_error != OK:
		print('Error opening ', path, ', ', error_string(open_error))
		return

	print('loaded ',path)

	var ln_idx := 0
	while file.get_position() < file.get_length():
		ln_idx += 1
		var line := file.get_line()
#
		var comment_check := line.strip_edges()
		if comment_check.begins_with('#'):
			continue
		if comment_check.length() == 0:
			continue
		if not comment_check.contains('='):
			printerr('Error parsing %s, there may be no value at line %s' %[path, str(ln_idx)])
			continue

		var regex = RegEx.create_from_string(REGEX_PATTERN)
		var match_ = regex.search(line)

		var key_valid = validate_env_str(match_.get_string(1), 'key', path, ln_idx)
		if not key_valid[0]:
			continue
		var value_valid = validate_env_str(match_.get_string(2), 'value', path, ln_idx)
		if not value_valid[0]:
			continue

		OS.set_environment(key_valid[1], value_valid[1])


static func validate_env_str(string: String, type: String, path: String, ln_idx: int) -> Array:
	if string.length() == 0:
		printerr('Error parsing %s, the length of the %s at line %s is 0' %[path, type, str(ln_idx)])
		return [false, '']

	# Check if there is not a match in the quotes
	if (string.begins_with("'") and string.ends_with('"')) or (string.begins_with('"') and string.ends_with("'")):
		printerr('Error parsing %s, the quotes around %s at line %s are not the same' %[path, type, str(ln_idx)])
		return [false, '']

	if string.begins_with("'") and string.ends_with("'"):
		return [true, string.trim_prefix("'").trim_suffix("'")]

	if string.begins_with('"') and string.ends_with('"'):
		return [true, string.trim_prefix('"').trim_suffix('"')]

	if string.count(' ') == 0:
		return [true, string]

	if string.count(' ') > 0:
		printerr('Error parsing %s, there is a space in %s at line %s, expected quotes' %[path, type, str(ln_idx)])
		return [false, '']

	return [false, '']
