extends Control

@onready var btn_close: Button = %btn_close
@onready var grid_container: GridContainer = %GridContainer

signal btn_close_pressed
signal level_selected

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
