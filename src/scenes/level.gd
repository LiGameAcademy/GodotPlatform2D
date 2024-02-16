extends Node2D

@onready var parallax_background: ParallaxBackground = $ParallaxBackground
@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer
@onready var control: Control = $CanvasLayer/Control
@onready var mask_dude: CharacterBody2D = $mask_dude

@export var speed : float = 80

func _ready() -> void:
	var material = control.material
	if material is ShaderMaterial:
		material.set_shader_parameter("character_position", Vector3(mask_dude.position.x, mask_dude.position.y, 0))

func _process(delta: float) -> void:
	## 在每一帧改变视差层的motion_offset属性的x值即可实现视差背景的滚动效果
	if parallax_background.scroll_offset.y >= parallax_layer.motion_mirroring.y:
		parallax_background.scroll_offset.y = 0
	parallax_background.scroll_offset.y += delta * speed
