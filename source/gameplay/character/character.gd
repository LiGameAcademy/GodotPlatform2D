extends CharacterBody2D
class_name Character

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/StateMachine/playback")

# 基础移动参数
@export_group("Movement")
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var wall_slide_speed = 50
@export_range(0.0, 1.0) var friction = 0.2

# 动画参数
@export_group("Animation")
@export var base_animation_speed = 1.0
@export var max_animation_speed = 1.5
@export var wall_slide_anim_scale = 0.7
@export_range(0.0, 1.0) var speed_scale_factor = 0.5

# 混合空间参数
@export_group("Blend Space")
@export var air_blend_threshold = 1.0

# 跳跃优化参数
@export_group("Jump Feel")
@export var coyote_time = 0.1      # 土狼时间窗口
# @export var jump_buffer_time = 0.1 # 跳跃输入缓冲时间
@export var jump_cut_height = 0.5  # 跳跃高度控制系数

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_double_jump = true
var current_animation: String = ""

# 玩家正常时应与层2和层3碰撞（二进制110，十进制6）
var normal_mask = (1 << 1) | (1 << 2)
# 按下"下"键时，玩家应与层2碰撞，忽略层3（二进制100，十进制4）
var pass_through_mask = 1 << 1

# 角色状态
var _wants_to_jump := false
var _wants_to_jump_release := false

# 预览模式标志
var is_preview_mode := false

func _ready() -> void:
	_animation_tree.active = true
	var state_machine = CharacterStateMachine.new()
	CoreSystem.state_machine_manager.register_state_machine(&"character_%d" % get_instance_id(), state_machine, self, &"ground")
	
	# 查找并连接控制器信号
	for child in get_children():
		if child is CharacterController:
			_connect_controller(child)

func _exit_tree() -> void:
	_animation_tree.active = false
	CoreSystem.state_machine_manager.unregister_state_machine(&"character_%d" % get_instance_id())
	request_ready()

func _physics_process(delta: float) -> void:
	if is_preview_mode:
		return
		
	# 应用重力
	_apply_gravity(delta)
	
	# 更新朝向
	_update_facing_direction()
	
	# 应用地面摩擦力
	_apply_ground_friction()
	
	# 应用最终移动
	move_and_slide()

	# 更新动画参数
	_update_animation_parameters()

## 应用重力
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

## 更新朝向
func _update_facing_direction() -> void:
	if signf(velocity.x) != 0:
		_sprite.flip_h = velocity.x < 0

## 应用地面摩擦力
func _apply_ground_friction() -> void:
	if is_on_floor() and abs(velocity.x) > 0.1:
		velocity.x *= (1 - friction)

## 播放动画
func play_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		current_animation = anim_name
		_animation_state_machine.travel(anim_name)

## 是否正在移动
func is_moving() -> bool:
	return abs(velocity.x) > 0.1

## 死亡
func die() -> void:
	# 发送死亡事件
	CoreSystem.event_bus.push_event("character_died", self)
	# 禁用物理和输入处理
	set_physics_process(false)
	set_process_input(false)

## 重生
## [param respawn_position] 重生位置
func respawn(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	visible = true
	set_physics_process(true)
	set_process_input(true)

## 是否想要跳跃
func wants_to_jump() -> bool:
	var wants = _wants_to_jump
	_wants_to_jump = false  # 消费跳跃请求
	return wants

## 是否想要释放跳跃
func wants_to_jump_release() -> bool:
	var wants = _wants_to_jump_release
	_wants_to_jump_release = false  # 消费释放请求
	return wants

## 更新动画参数
func _update_animation_parameters() -> void:
	# 更新动画速度
	var speed_scale = base_animation_speed
	if is_moving():
		# 根据移动速度调整动画速度
		var speed_factor = abs(velocity.x) / SPEED * speed_scale_factor
		speed_scale = base_animation_speed + speed_factor * (max_animation_speed - base_animation_speed)
	elif is_on_wall() and velocity.y > 0:
		# 墙壁滑行时减慢动画
		speed_scale = wall_slide_anim_scale
	_animation_tree["parameters/TimeScale/scale"] = speed_scale
	
	# 更新Move状态的混合位置
	if current_animation == "Move":
		var blend_pos = 0.0  # 默认为移动动画
		if not is_on_floor():
			# 在空中时，根据垂直速度更新混合位置
			blend_pos = clampf(velocity.y / (JUMP_VELOCITY * air_blend_threshold), -1.0, 1.0)
		_animation_tree["parameters/StateMachine/Move/blend_position"] = blend_pos

func _connect_controller(controller: CharacterController) -> void:
	# 连接控制器信号
	controller.jump_requested.connect(func(): _wants_to_jump = true)
	controller.jump_released.connect(func(): _wants_to_jump_release = true)
