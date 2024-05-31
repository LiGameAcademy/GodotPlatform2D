extends Node2D

#const MASK_DUDE = preload("res://source/entity/character/mask_dude.tscn")

@onready var parallax_background: ParallaxBackground = $ParallaxBackground
@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer
@onready var control: Control = $CanvasLayer/Control
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

@export var player_start : Marker2D = null
@export var speed : float = 80
var P_CHA : PackedScene
var _player : Character = null

@export var level_index : int = 0

signal end

func _ready() -> void:
	#var material = control.material
	#if material is ShaderMaterial:
		#material.set_shader_parameter("character_position", Vector3(mask_dude.position.x, mask_dude.position.y, 0))
	$end.end.connect(
		func() -> void:
			await exit_level()
			end.emit(level_index)
	)

func _process(delta: float) -> void:
	## 在每一帧改变视差层的motion_offset属性的x值即可实现视差背景的滚动效果
	if parallax_background.scroll_offset.y >= parallax_layer.motion_mirroring.y:
		parallax_background.scroll_offset.y = 0
	parallax_background.scroll_offset.y += delta * speed

## 初始化
func initialize(cha_scene : PackedScene) -> void:
	await enter_level()
	P_CHA = cha_scene
	spawn_character()

## 生成玩家角色
func spawn_character() -> void:
	assert(player_start, "player_start is null!!!")
	_player = P_CHA.instantiate()
	_player.set_process(false)
	await get_tree().create_timer(0.3).timeout
	_player.set_process(true)
	add_child(_player)
	_player.died.connect(
		func() -> void:
			spawn_character()
	)
	_player.global_position = player_start.global_position
	$start.start()

func exit_level() -> void:
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 1, 1.5).from(0)
	await tween.finished

func enter_level() -> void:
	color_rect.color = Color.BLACK
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 0, 1.5).from(1)
	await tween.finished
