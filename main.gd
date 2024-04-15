extends CanvasLayer
class_name main

const MENU = preload("res://source/scenes/menu.tscn")

const MENU_FORM = preload("res://source/UI/menu_form.tscn")
const SELECT_FORM = preload("res://source/UI/select_form.tscn")

@onready var ui_layer: CanvasLayer = %UILayer
@onready var state_chart: StateChart = $StateChart

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
	_current_scene = MENU.instantiate()
	_current_form = MENU_FORM.instantiate()
	_current_form.btn_new_game_pressed.connect(
		func() -> void:
			state_chart.send_event("to_select")
	)

func _on_select_state_state_entered() -> void:
	_current_form = SELECT_FORM.instantiate()
	_current_form.btn_close_pressed.connect(
		func() -> void:
			state_chart.send_event("to_menu")
	)
	_current_form.level_selected.connect(
		func(level) -> void:
			state_chart.set_meta("level", level)
			state_chart.send_event("to_game")
	)

func _on_game_state_state_entered() -> void:
	_current_form = null
	_current_scene = state_chart.get_meta("level").instantiate()
	_current_scene.initialize()
