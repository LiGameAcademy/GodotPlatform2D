extends CharacterController
class_name PlayerController

## 玩家控制器，处理玩家输入并控制角色

## 输入动作名称
const INPUT_ACTIONS = {
	"right": "ui_right",
	"left": "ui_left",
	"jump": "ui_up",
	"crouch": "ui_down"
}
## 移动轴名称
const MOVEMENT_AXES_NAME : StringName = "player_move"

## 输入管理器引用
@onready var input_manager: CoreSystem.InputManager = CoreSystem.input_manager
## 调试模式
@export var debug_mode: bool = true

func _ready() -> void:
	if not input_manager:
		push_error("未找到输入管理器")
		return
	
	# 连接信号
	input_manager.action_triggered.connect(_on_action_triggered)
	input_manager.axis_changed.connect(_on_axis_changed)

	super()

## 设置输入系统
func _setup() -> void:
	_setup_input_actions()

	# 注册移动轴（只注册水平移动）
	input_manager.virtual_axis.register_axis(
		MOVEMENT_AXES_NAME, 
		INPUT_ACTIONS.right,   # 正向（右）
		INPUT_ACTIONS.left,    # 负向（左）
		"",                    # 不使用上下方向
		""
	)
	
	# 设置轴参数
	input_manager.virtual_axis.set_sensitivity(1.0)  # 默认灵敏度
	input_manager.virtual_axis.set_deadzone(0.2)     # 20%的死区
	
	if debug_mode:
		print("输入系统初始化完成")

## 设置输入动作
func _setup_input_actions() -> void:
	# 注册跳跃动作
	if not InputMap.has_action(INPUT_ACTIONS.jump):
		InputMap.add_action(INPUT_ACTIONS.jump)
		var jump_event = InputEventKey.new()
		jump_event.keycode = KEY_SPACE  # 使用空格键跳跃
		InputMap.action_add_event(INPUT_ACTIONS.jump, jump_event)
		
		if debug_mode:
			print("注册跳跃动作")
	
	# 注册下蹲动作
	if not InputMap.has_action(INPUT_ACTIONS.crouch):
		InputMap.add_action(INPUT_ACTIONS.crouch)
		var crouch_event = InputEventKey.new()
		crouch_event.keycode = KEY_S  # 使用S键下蹲
		InputMap.action_add_event(INPUT_ACTIONS.crouch, crouch_event)
		
		if debug_mode:
			print("注册下蹲动作")

## 处理输入
func _handle_input() -> void:
	# 获取移动轴的值（只使用水平分量）
	var axis_value = input_manager.virtual_axis.get_axis_value(MOVEMENT_AXES_NAME)
	_movement_input.x = axis_value.x
	
	# 检查跳跃状态
	_jump_pressed = input_manager.input_state.is_just_pressed(INPUT_ACTIONS.jump)
	_jump_released = input_manager.input_state.is_just_released(INPUT_ACTIONS.jump)
	
	# 检查下蹲状态
	_crouch_pressed = input_manager.input_state.is_just_pressed(INPUT_ACTIONS.crouch)
	
	if debug_mode:
		_debug_input_state()

## 调试输入状态
func _debug_input_state() -> void:
	if _movement_input != Vector2.ZERO:
		print("移动输入: ", _movement_input)
	if _jump_pressed:
		print("跳跃按下")
	if _jump_released:
		print("跳跃释放")
	if _crouch_pressed:
		print("下蹲触发")

## 输入动作触发回调
func _on_action_triggered(action_name: String, _event: InputEvent) -> void:
	if debug_mode:
		print("动作触发: ", action_name)

## 轴值变化回调
func _on_axis_changed(axis_name: String, value: Vector2) -> void:
	if debug_mode and axis_name == MOVEMENT_AXES_NAME:
		print("移动轴值: ", value)
