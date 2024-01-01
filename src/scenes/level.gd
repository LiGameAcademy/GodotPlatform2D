extends Node2D

@onready var parallax_background: ParallaxBackground = $ParallaxBackground
@export var speed : float = 80
@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer

func _process(delta: float) -> void:
	## 在每一帧改变视差层的motion_offset属性的x值即可实现视差背景的滚动效果
	if parallax_background.scroll_offset.y >= parallax_layer.motion_mirroring.y:
		parallax_background.scroll_offset.y = 0
	parallax_background.scroll_offset.y += delta * speed
