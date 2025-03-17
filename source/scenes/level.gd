extends Node2D

@onready var control: Control = $CanvasLayer/Control
@onready var color_rect: ColorRect = %Transition
@onready var end: Node2D = $End
@onready var start: Node2D = $Start

@export var speed : float = 80
var P_CHA : PackedScene
var _player : Character = null

@export var level_index : int = 0

signal ended

func _ready() -> void:
	$End.end.connect(
		func() -> void:
			await exit_level()
			ended.emit(level_index)
	)


## 初始化
func initialize(cha_scene : PackedScene) -> void:
	await enter_level()
	P_CHA = cha_scene
	spawn_character()

## 生成玩家角色
func spawn_character() -> void:
	_player = P_CHA.instantiate()
	_player.set_process(false)
	await get_tree().create_timer(0.3).timeout
	_player.set_process(true)
	add_child(_player)
	_player.died.connect(
		func() -> void:
			spawn_character()
	)
	_player.global_position = start.global_position
	start.start()

func exit_level() -> void:
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 1, 1.5).from(0)
	await tween.finished

func enter_level() -> void:
	color_rect.color = Color.BLACK
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 0, 1.5).from(1)
	await tween.finished
