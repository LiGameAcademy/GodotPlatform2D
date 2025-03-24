extends CharacterController
class_name PlayerController

## 玩家控制器，处理玩家输入并控制角色

func _handle_input() -> void:
	# 处理移动输入
	_movement_input.x = Input.get_axis("ui_left", "ui_right")
	
	# 处理跳跃输入
	_jump_pressed = Input.is_action_just_pressed("ui_up")
	_jump_released = Input.is_action_just_released("ui_up")
	
	# 处理下蹲输入
	_crouch_pressed = Input.is_action_just_pressed("ui_down")
