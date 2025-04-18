extends Node
class_name CharacterController

## 角色控制器基类，负责处理角色的输入和行为控制

## 信号
signal jump_requested
signal jump_released
signal movement_changed(direction: float)

## 控制的角色引用
@export var controlled_character: Character

# 基础输入状态变量
## 移动输入
var _movement_input := Vector2.ZERO
## 跳跃输入
var _jump_pressed := false
var _jump_released := false
## 下蹲输入
var _crouch_pressed := false

func _ready() -> void:
	if not controlled_character:
		# 获取父节点作为被控制的角色
		controlled_character = get_parent() as Character
	if not controlled_character:
		push_error("未设置控制的角色")
		return
	
	_setup()

## 更新角色行为
func _physics_process(_delta: float) -> void:
	if not controlled_character:
		return
	
	# 清除上一帧的输入状态
	_reset_input_state()
	# 处理输入
	_handle_input()
	# 应用移动
	_apply_movement()
	
	# 更新角色状态
	controlled_character.move_and_slide()
	
	# 发送信号
	if _jump_pressed:
		jump_requested.emit()
	if _jump_released:
		jump_released.emit()
	
	# 应用下蹲
	if _crouch_pressed:
		pass_through_platform()

## 重置输入状态
func _reset_input_state() -> void:
	_movement_input = Vector2.ZERO
	_jump_pressed = false
	_jump_released = false
	_crouch_pressed = false

## 应用移动
func _apply_movement() -> void:
	if not controlled_character:
		return
		
	var target_velocity := Vector2.ZERO
	
	if _movement_input != Vector2.ZERO:
		# 计算目标速度
		target_velocity.x = _movement_input.x * controlled_character.SPEED
		# 发送移动方向变化信号
		movement_changed.emit(_movement_input.x)
	
	# 直接设置速度，摩擦力的处理交给角色类
	controlled_character.velocity.x = target_velocity.x

## 穿过单向平台
func pass_through_platform() -> void:
	if controlled_character.is_on_floor():
		controlled_character.collision_mask = controlled_character.pass_through_mask
		await controlled_character.get_tree().create_timer(0.1).timeout
		controlled_character.collision_mask = controlled_character.normal_mask

## 设置控制器，子类可以重写此方法进行额外设置
func _setup() -> void:
	pass

## 处理输入，子类必须实现此方法
func _handle_input() -> void:
	pass
