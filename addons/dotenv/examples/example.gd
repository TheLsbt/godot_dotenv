extends Node


func _ready() -> void:
	Dotenv.load_dotenv('res://addons/dotenv/examples/example.env')
	print(OS.get_environment('FUNNY_WORD'))
