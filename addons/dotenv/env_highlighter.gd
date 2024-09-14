@tool
extends EditorSyntaxHighlighter

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
