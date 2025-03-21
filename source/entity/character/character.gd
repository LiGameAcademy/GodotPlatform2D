extends CharacterBody2D
class_name Character

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine : AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/StateMachine/playback")

# 基础移动参数
@export_group("Movement")
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var wall_slide_speed = 50 # 定义墙滑行时的最大下落速度

# 动画参数
@export_group("Animation")
@export var base_animation_speed = 1.0  # 基础动画速度
@export var max_animation_speed = 1.5   # 最大动画速度
@export var wall_slide_anim_scale = 0.7 # 墙壁滑行动画速度
@export_range(0.0, 1.0) var speed_scale_factor = 0.5 # 速度对动画的影响因子

# 混合空间参数
@export_group("Blend Space")
@export var air_blend_threshold = 1.0 # 空中混合阈值，用于调整跳跃/下落动画的过渡

# 道具收集参数
@export_group("Collection")
@export var collection_score = 100  # 每个道具的基础分数
@export var combo_time_window = 2.0 # 连击时间窗口（秒）
@export var max_combo = 5          # 最大连击数

# 跳跃优化参数
@export_group("Jump Feel")
@export var coyote_time = 0.1      # 土狼时间窗口
@export var jump_buffer_time = 0.1 # 跳跃输入缓冲时间
@export var jump_cut_height = 0.5  # 跳跃高度控制系数

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_double_jump = true
var current_animation: String = ""

# 玩家正常时应与层2和层3碰撞（二进制110，十进制6）
var normal_mask = (1 << 1) | (1 << 2)
# 按下"下"键时，玩家应与层2碰撞，忽略层3（二进制100，十进制4）
var pass_through_mask = 1 << 1

# 道具收集状态
var _collected_items = 0       # 收集的道具总数
var _current_combo = 0        # 当前连击数
var _combo_timer: float = 0.0 # 连击计时器
var _total_score = 0          # 总分数

# 跳跃优化状态
var _coyote_timer: float = 0.0     	# 土狼时间计时器
var _jump_buffer_timer: float = 0.0 # 跳跃缓冲计时器
var _was_on_floor: bool = false     # 上一帧是否在地面
var _is_jumping: bool = false       # 是否正在跳跃

# 预览模式标志
var is_preview_mode := false

signal died
signal item_collected(item_type: String, combo: int, score: int)
signal combo_ended(final_combo: int)
signal jumped                # 跳跃信号
signal landed               # 着陆信号


func _ready() -> void:
	_animation_tree.active = true
	var state_machine = CharacterStateMachine.new()
	CoreSystem.state_machine_manager.register_state_machine(&"character_%d" % get_instance_id(), state_machine, self, &"ground")

func _exit_tree() -> void:
	_animation_tree.active = false
	CoreSystem.state_machine_manager.unregister_state_machine(&"character_%d" % get_instance_id())
	request_ready()

func _physics_process(delta: float) -> void:
	if is_preview_mode:
		return
		
	_update_timers(delta)
	_handle_movement(delta)
	_handle_jump()
	move_and_slide()
	_update_animation_parameters()
	_update_combo_timer(delta)
	_update_floor_state()


## 更新计时器
func _update_timers(delta: float) -> void:
	# 更新土狼时间
	if _coyote_timer > 0:
		_coyote_timer -= delta
	
	# 更新跳跃缓冲
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta


## 处理移动
func _handle_movement(delta: float) -> void:
	# 处理水平移动
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# 更新精灵朝向
	if signf(velocity.x) != 0:
		_sprite.flip_h = velocity.x < 0
	
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 处理下落穿透
	if Input.is_action_just_pressed("ui_down"):
		collision_mask = pass_through_mask
		await get_tree().create_timer(0.1).timeout
		collision_mask = normal_mask


## 处理跳跃
func _handle_jump() -> void:
	# 检测跳跃输入
	if Input.is_action_just_pressed("ui_up"):
		_jump_buffer_timer = jump_buffer_time
	
	# 处理跳跃释放（控制跳跃高度）
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= jump_cut_height
	
	# 尝试执行跳跃
	if _can_jump():
		_perform_jump()
	# 尝试执行二段跳
	elif _can_double_jump():
		_perform_double_jump()


## 检查是否可以跳跃
func _can_jump() -> bool:
	return (_jump_buffer_timer > 0 and 
			(is_on_floor() or _coyote_timer > 0))


## 检查是否可以二段跳
func _can_double_jump() -> bool:
	return (_jump_buffer_timer > 0 and 
			can_double_jump and 
			not is_on_floor() and 
			_coyote_timer <= 0)


## 执行跳跃
func _perform_jump() -> void:
	velocity.y = JUMP_VELOCITY
	_jump_buffer_timer = 0
	_coyote_timer = 0
	_is_jumping = true
	emit_signal("jumped")


## 执行二段跳
func _perform_double_jump() -> void:
	velocity.y = JUMP_VELOCITY * 0.8  # 二段跳稍微弱一些
	can_double_jump = false
	_jump_buffer_timer = 0
	emit_signal("jumped")


## 更新地面状态
func _update_floor_state() -> void:
	# 检测是否刚离开地面
	if _was_on_floor and not is_on_floor():
		_coyote_timer = coyote_time
	# 检测是否刚着陆
	elif not _was_on_floor and is_on_floor():
		_is_jumping = false
		can_double_jump = true
		emit_signal("landed")
	
	_was_on_floor = is_on_floor()


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
	if not is_on_floor():
		# 在空中时，根据垂直速度更新混合位置
		var blend_pos = clampf(velocity.y / (JUMP_VELOCITY * air_blend_threshold), -1.0, 1.0)
		_animation_tree["parameters/StateMachine/Move/blend_position"] = blend_pos


## 更新连击计时器
func _update_combo_timer(delta: float) -> void:
	if _current_combo > 0:
		_combo_timer -= delta
		if _combo_timer <= 0:
			combo_ended.emit(_current_combo)
			_current_combo = 0


## 播放动画
func play_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		current_animation = anim_name
		_animation_state_machine.travel(anim_name)


## 是否正在移动
func is_moving() -> bool:
	return abs(velocity.x) > 0.1


## 是否正在跳跃
func is_jumping() -> bool:
	return Input.is_action_just_pressed("ui_up")


## 收集道具
func collect_item(item_type: String = "") -> void:
	_collected_items += 1
	
	# 更新连击
	_current_combo = min(_current_combo + 1, max_combo)
	_combo_timer = combo_time_window
	
	# 计算分数
	var combo_multiplier = 1.0 + (_current_combo - 1) * 0.5  # 每次连击增加50%分数
	var score = roundi(collection_score * combo_multiplier)
	_total_score += score
	
	# 发出信号
	item_collected.emit(item_type, _current_combo, score)


## 获取收集数据
func get_collection_data() -> Dictionary:
	return {
		"collected_items": _collected_items,
		"current_combo": _current_combo,
		"total_score": _total_score
	}


## 死亡
func die() -> void:
	# CoreSystem.state_machine_manager.get_state_machine(&"character_%d" % get_instance_id()).switch(&"dead")
	CoreSystem.event_bus.push_event("character_died", self)
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	died.emit()
	queue_free()
