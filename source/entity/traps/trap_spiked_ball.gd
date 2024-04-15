@tool
extends Node2D

const CHAIN = preload("res://assets/textures/traps/Spiked Ball/Chain.png")

@onready var ball: CharacterBody2D = $ball

@export var chain_width : float = 10.0
@export var clamp_rotation : Vector2 = Vector2(0, 180)
## 设置旋转速度，单位是弧度/秒
@export var rotation_speed = 1.0
var _chains : Array[Sprite2D] = []
var radius : float = 0.0

func _ready() -> void:
	radius = ball.global_position.distance_to(global_position)
	var points = radius / chain_width
	for point in points:
		var chain = Sprite2D.new()
		chain.texture = CHAIN
		add_child(chain)
		_chains.append(chain)
		chain.position = point * chain_width * global_position.direction_to(ball.global_position)
	#update_ball_position(deg_to_rad(clamp_rotation.x))

func _process(delta: float) -> void:
	var current_angle = position.angle_to_point(ball.position)  # 获取当前角度
	current_angle += rotation_speed * delta  # 更新角度
	#if current_angle >= deg_to_rad(clamp_rotation.y) :
	#current_angle = deg_to_rad(clamp_rotation.x)
	print(current_angle)
	# 计算新的位置
	var new_x = radius * cos(current_angle)
	var new_y = radius * sin(current_angle)
 	# 更新CharacterBody2D的位置
	ball.position = Vector2(new_x, new_y)

func update_ball_position(angle : float) -> void:
	# 计算新的位置
	var new_x = radius * cos(angle)
	var new_y = radius * sin(angle)
 	# 更新CharacterBody2D的位置
	ball.position = Vector2(new_x, new_y)
	#update_chain_display()

func update_chain_display() -> void:
	var index : int = 1
	for chain in _chains:
		chain.position = index * chain_width * global_position.direction_to(ball.global_position)
		index += 1
