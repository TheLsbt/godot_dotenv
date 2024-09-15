extends Node


func _ready() -> void:
	Dotenv.load('res://addons/dotenv/examples/example.env')
	print(OS.get_environment('PASSWORD'))
