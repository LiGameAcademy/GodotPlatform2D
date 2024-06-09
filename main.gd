extends CanvasLayer
class_name main

# const MENU = preload("res://source/scenes/menu.tscn")
const GAME_FORM = preload("res://source/UI/game_form.tscn")
const MENU_FORM = preload("res://source/UI/menu_form.tscn")
const SELECT_LEVEL_FORM = preload("res://source/UI/select_level_form.tscn")
const SELECT_CHA_FORM = preload("res://source/UI/select_cha_form.tscn")

@onready var ui_layer: CanvasLayer = %UILayer
@onready var state_chart: StateChart = $StateChart

@export var _levels : Array[PackedScene]

var _current_scene = null : 
	set(value) :
		if _current_scene:
			remove_child(_current_scene)
		_current_scene = value
		if _current_scene:
			add_child(_current_scene)
var _current_form = null :
	set(value) :
		if _current_form:
			ui_layer.remove_child(_current_form)
		_current_form = value
		if _current_form:
			ui_layer.add_child(_current_form)

func _on_menu_state_state_entered() -> void:
	#_current_scene = MENU.instantiate()
	_current_form = MENU_FORM.instantiate()
	_current_form.btn_new_game_pressed.connect(
		func() -> void:
			state_chart.send_event("to_select_character")
	)

func _on_select_character_state_state_entered() -> void:
	_current_form = SELECT_CHA_FORM.instantiate()
	_current_form.btn_close_pressed.connect(
		func() -> void:
			state_chart.send_event("to_menu")
	)
	_current_form.btn_enter_game_pressed.connect(
		func(P_CHA : PackedScene) -> void:
			state_chart.set_meta("P_CHA", P_CHA)
			state_chart.send_event("to_select_level")
	)

func _on_select_state_state_entered() -> void:
	_current_form = SELECT_LEVEL_FORM.instantiate()
	_current_form.btn_close_pressed.connect(
		func() -> void:
			state_chart.send_event("to_select_character")
	)
	_current_form.level_selected.connect(
		func(level) -> void:
			state_chart.set_meta("level", level)
			state_chart.send_event("to_game")
	)

func _on_game_state_state_entered() -> void:
	_current_scene = state_chart.get_meta("level").instantiate()
	_current_scene.ended.connect(
		func (level_index : int) -> void:
			var level = _levels[level_index if level_index < _levels.size() - 1 else _levels.size() - 1]
			load_level(level)
	)
	var P_CHA : PackedScene = state_chart.get_meta("P_CHA")
	_current_scene.initialize(P_CHA)
	_current_form = GAME_FORM.instantiate()
	if _current_scene.level_index == 1:
		_current_form.btn_previous.disabled = true
	elif _current_scene.level_index == _levels.size():
		_current_form.btn_next.disabled = true
	_current_form.btn_previous_pressed.connect(
		func() -> void:
			var level_index = _current_scene.level_index
			var level = _levels[clamp(level_index - 1, 1, _levels.size())  - 1]
			load_level(level)
	)
	_current_form.btn_restart_pressed.connect(
		func() -> void:
			load_level(_levels[_current_scene.level_index - 1])
	)	
	_current_form.btn_next_pressed.connect(
		func() -> void:
			var level_index = _current_scene.level_index
			#var level = _levels[level_index if level_index < _levels.size() - 1 else _levels.size() - 1]
			var level = _levels[clamp(level_index + 1, 1, _levels.size())  - 1]
			load_level(level)
	)	
	_current_form.btn_settings_pressed.connect(
		func() -> void:
			pass
	)

func load_level(level) -> void:
	state_chart.set_meta("level", level)
	state_chart.send_event("to_game")
