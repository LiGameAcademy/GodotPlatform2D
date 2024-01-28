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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = textures.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
