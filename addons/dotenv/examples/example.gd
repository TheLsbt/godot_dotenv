extends Node


func _ready() -> void:
	Godotenv.load('res://addons/dotenv/examples/example.env')
	print(OS.get_environment('FUNNY_WORD'))
