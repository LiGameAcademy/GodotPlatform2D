@tool
extends Node2D

const CHAIN = preload("res://assets/textures/traps/Spiked Ball/Chain.png")

@onready var ball: CharacterBody2D = $ball

@export var chain_width : float = 10.0
@export var clamp_rotation : Vector2 = Vector2(30, 160)
## 设置旋转速度，单位是弧度/秒
@export var rotation_speed = 1.0
var _chains : Array[Sprite2D] = []
var radius : float = 0.0
@export var is_move : bool = false
var _is_reversal : bool = false

func _ready() -> void:
	radius = ball.global_position.distance_to(global_position)
	var points = radius / chain_width
	for point in points:
		var chain = Sprite2D.new()
		chain.texture = CHAIN
		add_child(chain)
		_chains.append(chain)
		#chain.global_position = point * chain_width * global_position.direction_to(ball.global_position)
	update_chain_display()
	#update_ball_position(deg_to_rad(clamp_rotation.x))
	#print(rad_to_deg(global_position.angle_to_point(ball.global_position)))
	is_move = true

func _process(delta: float) -> void:
	if not is_move : return
	var current_angle = global_position.angle_to_point(ball.global_position)  # 获取当前角度
	if rad_to_deg(current_angle) >= clamp_rotation.y:
		_is_reversal = true
	if rad_to_deg(current_angle) <= clamp_rotation.x:
		_is_reversal = false
	if _is_reversal:
		current_angle -= rotation_speed * delta  # 更新角度
	else:
		current_angle += rotation_speed * delta  # 更新角度
	#if current_angle >= deg_to_rad(clamp_rotation.y) :
	#current_angle = deg_to_rad(clamp_rotation.x)
	#print(current_angle)
	# 计算新的位置
	#var new_x = radius * cos(current_angle)
	#var new_y = radius * sin(current_angle)
 	## 更新CharacterBody2D的位置
	#ball.global_position = Vector2(new_x, new_y)
	update_ball_position(current_angle)

func update_ball_position(angle : float) -> void:
	# 计算新的位置
	var new_x = radius * cos(angle) + global_position.x
	var new_y = radius * sin(angle) + global_position.y
 	# 更新CharacterBody2D的位置
	ball.global_position = Vector2(new_x, new_y)
	update_chain_display()

func update_chain_display() -> void:
	var index : int = 1
	for chain in _chains:
		chain.global_position = global_position + index * chain_width * global_position.direction_to(ball.global_position)
		#chain.position = index * chain_width * position.direction_to(position)
		index += 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")
