extends Node

## Loads files directly into the enviroment
## This is mostly for local develoment, use something like github secrets for production
## code.

enum ENV_STR_VALIDATION {
	SINGLE, DOUBLE, NO_QUOTE, NONE, FAILED, NON_MATCHING_QUOTE
}

const REGEX_PATTERN = '^(.*?) *= *(.*?)$'


func _ready() -> void:
	load_dotenv("res://erros.env")


# TODO: allow to search through a directory
func load_dotenv(path: String) -> void:
	var enviroment := {}
	if not FileAccess.file_exists(path):
		printerr('File at ', path, 'does not exsist')
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var line_idx := 0
	while file.get_position() < file.get_length():
		line_idx += 1
		var line := file.get_line()

		var comment_check := line.strip_edges()
		if comment_check.begins_with('#'):
			continue
		if comment_check.length() == 0:
			continue
		if not comment_check.contains('='):
			printerr('Error parsing %s, there may be no value at line %s' %[path, str(line_idx)])
			continue

		var regex = RegEx.create_from_string(REGEX_PATTERN)
		var match_ = regex.search(line)

		var key_valid = validate_env_str(match_.get_string(1), 'key', path, line_idx)
		if not key_valid[0]:
			continue
		var value_valid = validate_env_str(match_.get_string(2), 'value', path, line_idx)
		if not value_valid[0]:
			continue

		enviroment[key_valid[1]] = value_valid[1]

	print(enviroment)


func validate_env_str(string: String, type: String, path: String, ln_idx: int) -> Array:
	if string.count(' ') == 0:
		return [true, string]

	if string.length() == 0:
		printerr('Error parsing %s, the length of the %s at line %s is 0' %[path, type, str(ln_idx)])
		return [false, '']

	# Check if there is not a match in the quotes
	if (string.begins_with("'") and string.ends_with('"')) or (string.begins_with('"') and string.ends_with("'")):
		printerr('Error parsing %s, the quotes around %s at line %s are not the same' %[path, type, str(ln_idx)])
		return [false, '']

	if string.count(' ') > 0:
		printerr('Error parsing %s, there is a space in %s at line %s, expected quotes' %[path, type, str(ln_idx)])
		return [false, '']

	if string.begins_with("'") and string.ends_with("'"):
		return [true, string.trim_prefix("'").trim_suffix("'")]

	if string.begins_with('"') and string.ends_with('"'):
		return [true, string.trim_prefix('"').trim_suffix('"')]

	return [false, '']
