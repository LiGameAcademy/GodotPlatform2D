extends CharacterController
class_name PlayerController

## 玩家控制器，处理玩家输入并控制角色

var input_manager: Node

func _ready() -> void:
	super._ready()
	input_manager = CoreSystem.input_manager
	_register_inputs()

func _register_inputs() -> void:
	# 注册移动轴
	input_manager.register_axis("movement", "ui_right", "ui_left", "", "")
	
	# 可以在这里注册更多的输入映射
	# 比如跳跃、下蹲等动作都可以在这里配置

func _handle_input() -> void:
	# 处理移动输入
	var movement = input_manager.get_axis_value("movement")
	_movement_input.x = movement.x
	
	# 处理跳跃输入（包含缓冲）
	_jump_pressed = input_manager.is_action_buffered("ui_up") or input_manager.is_action_just_pressed("ui_up")
	_jump_released = input_manager.is_action_just_released("ui_up")
	
	# 处理下蹲输入
	_crouch_pressed = input_manager.is_action_just_pressed("ui_down")
