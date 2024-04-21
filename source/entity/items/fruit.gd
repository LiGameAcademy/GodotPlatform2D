extends Node2D

var textures: Array[Texture] = [
	preload("res://assets/textures/items/Fruits/Bananas.png"),
	preload("res://assets/textures/items/Fruits/Cherries.png"),
	preload("res://assets/textures/items/Fruits/Kiwi.png"),
	preload("res://assets/textures/items/Fruits/Melon.png"),
	preload("res://assets/textures/items/Fruits/Orange.png"),
	preload("res://assets/textures/items/Fruits/Pineapple.png"),
	preload("res://assets/textures/items/Fruits/Strawberry.png"),
]
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_collected: Sprite2D = $sprite_collected

func _ready() -> void:
	sprite_2d.texture = textures.pick_random()

func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("collected")
	await get_tree().create_timer(2).timeout
	if body and is_instance_valid(body):
		# 在延时期间内body可能已经不存在，因此要进行判断
		body.collect()
	queue_free()
	
