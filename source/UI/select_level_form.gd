extends Control

@onready var btn_close: Button = %btn_close
@onready var grid_container: GridContainer = %GridContainer
@onready var btn_previous: Button = %btn_previous
@onready var btn_enter_game: Button = %btn_enter_game
@onready var btn_next: Button = %btn_next
@onready var character_point: Node2D = %character_point

signal btn_close_pressed
signal level_selected
var index : int = 0

func _ready() -> void:
	btn_close.pressed.connect(
		func() -> void:
			btn_close_pressed.emit()
	)
	for w_level in grid_container.get_children():
		w_level.pressed.connect(
			func() -> void:
				level_selected.emit(w_level.level_scene)
		)
