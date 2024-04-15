extends CharacterBody2D
class_name Character

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var wall_slide_speed = 50 # 定义墙滑行时的最大下落速度

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_double_jump = true

# 玩家正常时应与层2和层3碰撞（二进制110，十进制6）
var normal_mask = (1 << 1) | (1 << 2)
# 按下"下"键时，玩家应与层2碰撞，忽略层3（二进制100，十进制4）
var pass_through_mask = 1 << 1

func _process(delta: float) -> void:
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0
	var speed : float = abs(velocity.x)
	animation_tree.set("parameters/StateMachine/idle_run/blend_position", speed)

	# 根据垂直速度切换动画状态
	if velocity.y < 0:
		state_machine.travel("jump")
	elif velocity.y > 0 and not is_on_floor():
		state_machine.travel("fall")
	elif is_on_floor():
		state_machine.travel("idle_run") # 如果有idle状态的话

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_double_jump = true
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif can_double_jump: # 如果还可以进行二段跳
			velocity.y = JUMP_VELOCITY
			can_double_jump = false # 使用掉二段跳机会
			state_machine.travel("double_jump") # 切换到二段跳动画

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("ui_down"):
		# 允许通过单向平台
		collision_mask = pass_through_mask
		await get_tree().create_timer(0.5).timeout # 使用yield延迟恢复
		collision_mask = normal_mask
	if is_on_wall() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed) # 限制下落速度以模拟滑行
		state_machine.travel("wall_jump") # 切换到二段跳动画
	move_and_slide()
