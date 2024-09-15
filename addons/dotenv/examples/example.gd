extends Node


func _ready() -> void:
	Dotenv.load_('res://addons/dotenv/examples/example.env', false, false)
	print('username = ', OS.get_environment('USERNAME'))
	print('password = ', OS.get_environment('PASSWORD'))
	print('lucky number = ', OS.get_environment('LUCKY_NUMBER'))
