extends CharacterBody2D
class_name Character

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine : AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/StateMachine/playback")
@onready var _state_chart: StateChart = %StateChart

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var wall_slide_speed = 50 # 定义墙滑行时的最大下落速度

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var _is_on_ground = false
var coyote_time = 0.1  # 窗口时间0.1秒
var coyote_timer = 0.0

var can_double_jump = true

var jump_buffer_time = 0.2
var jump_buffer_timer = 0.0

# 玩家正常时应与层2和层3碰撞（二进制110，十进制6）
var normal_mask = (1 << 1) | (1 << 2)
# 按下"下"键时，玩家应与层2碰撞，忽略层3（二进制100，十进制4）
var pass_through_mask = 1 << 1

signal died

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	# flip the sprite. we do this before moving, so it flips
	# even if we stand at a wall
	if signf(velocity.x) != 0:
		_sprite.flip_h = velocity.x < 0
	move_and_slide()

	# handle gravity
	if is_on_floor():
		_state_chart.send_event("grounded")
		velocity.y = 0
	else:
		## apply gravity
		velocity.y += gravity * delta
		_state_chart.send_event("airborne")
	# let the state machine know if we are moving or not
	if velocity.length_squared() <= 0.005:
		_state_chart.send_event("idle")
	else:
		_state_chart.send_event("moving")
	# set the velocity to the animation tree, so it can blend between animations
	_animation_tree["parameters/StateMachine/Move/blend_position"] = signf(velocity.y)

	if Input.is_action_just_pressed("ui_down"):
		# 允许通过单向平台
		collision_mask = pass_through_mask
		await get_tree().create_timer(0.1).timeout
		collision_mask = normal_mask

	if is_on_wall() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed) # 限制下落速度以模拟滑行
		_state_chart.send_event("walled")

## 收集道具
func collect() -> void:
	pass

## 死亡
func die() -> void:
	_state_chart.send_event("die")
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	died.emit()
	queue_free()

## 土狼时间
func coyote(delta : float) -> void:
	#if is_on_floor():
			#_is_on_ground = true
			#coyote_timer = 0.0
	#else:
		#coyote_timer += delta
		#if coyote_timer > coyote_time:
			#_is_on_ground = false
	_is_on_ground = is_on_floor()

## 跳跃预处理
func _jump_buffer(delta : float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if is_on_floor() and jump_buffer_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0	

## Called in states that allow jumping, we process jumps only in these.
func _on_jump_enabled_state_physics_processing(delta):
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		_state_chart.send_event("jump")
	#_jump_buffer(delta)

## Called when the jump transition is taken in the double-jump
## state. Only used to play the double jump animation.
func _on_double_jump_jump():
	_animation_state_machine.travel("DoubleJump")

func _on_walled_jump() -> void:
	pass
