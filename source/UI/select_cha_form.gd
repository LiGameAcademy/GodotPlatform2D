extends Control

@onready var btn_close: Button = %btn_close
@onready var grid_container: GridContainer = %GridContainer
@onready var btn_previous: Button = %btn_previous
@onready var btn_enter_game: Button = %btn_enter_game
@onready var btn_next: Button = %btn_next
@onready var character_point: Node2D = %character_point

@export var _characters : Array[PackedScene]
var index : int = 0

signal btn_close_pressed
signal btn_enter_game_pressed(P_CHA : PackedScene)

func _ready() -> void:
	btn_close.pressed.connect(
		func() -> void:
			btn_close_pressed.emit()
	)
	btn_previous.pressed.connect(previous_character)
	btn_next.pressed.connect(next_character)
	btn_enter_game.pressed.connect(
		func() -> void:
			btn_enter_game_pressed.emit(_characters[index])
	)
	set_character()

func previous_character() -> void:
	index = index - 1 if index > 0 else _characters.size() - 1
	set_character()

func next_character() -> void:
	index = index + 1 if index < _characters.size() - 1 else 0
	set_character()

func set_character() -> void:
	var S_CHA : PackedScene = _characters[index]
	var cha : Character = S_CHA.instantiate()
	cha.set_script(null)
	character_point.remove_child(character_point.get_child(0))
	character_point.add_child(cha)
