extends Control
class_name MenuForm

@onready var btn_new_game: Button = %btn_new_game
@onready var btn_settings: Button = %btn_settings
@onready var btn_quit: Button = %btn_quit

signal btn_new_game_pressed

func _ready() -> void:
	btn_new_game.pressed.connect(
		func() -> void:
			btn_new_game_pressed.emit()
	)
	btn_settings.pressed.connect(
		func() -> void:
			pass
	)
	btn_quit.pressed.connect(
		func() -> void:
			get_tree().quit()
	)
