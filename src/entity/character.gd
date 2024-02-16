extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

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
	
	move_and_slide()
