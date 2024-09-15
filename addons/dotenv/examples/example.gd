extends Node


func _ready() -> void:
	Dotenv.load('res://addons/dotenv/examples/example.env')
	print('username = ', OS.get_environment('USERNAME'))
	print('password = ', OS.get_environment('PASSWORD'))
	print('lucky number = ', OS.get_environment('LUCKY_NUMBER'))
