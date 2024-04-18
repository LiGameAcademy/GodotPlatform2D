extends Control

@onready var btn_previous: Button = $MarginContainer/HBoxContainer/btn_previous
@onready var btn_restart: Button = $MarginContainer/HBoxContainer/btn_restart
@onready var btn_next: Button = $MarginContainer/HBoxContainer/btn_next
@onready var btn_settings: Button = $MarginContainer/HBoxContainer/btn_settings

signal btn_previous_pressed
signal btn_restart_pressed
signal btn_next_pressed
signal btn_settings_pressed

func _ready() -> void:
	btn_previous.pressed.connect(
		func () -> void:
			btn_previous_pressed.emit()
	)
	btn_restart.pressed.connect(
		func () -> void:
			btn_restart_pressed.emit()
	)
	btn_next.pressed.connect(
		func () -> void:
			btn_next_pressed.emit()
	)
	btn_settings.pressed.connect(
		func () -> void:
			btn_settings_pressed.emit()
	)
