extends CharacterController
class_name AIPatrolController

## AI巡逻控制器，让角色在平台上左右巡逻

## 巡逻参数
@export var patrol_distance := 100.0  # 巡逻距离
@export var edge_check_distance := 20.0  # 边缘检测距离

## 巡逻状态
var _initial_position: Vector2
var _moving_right := true
var _patrol_timer := 0.0

func _setup() -> void:
	_initial_position = controlled_character.global_position

func _handle_input() -> void:
	# 检查是否需要转向
	if _should_turn():
		_moving_right = not _moving_right
	
	# 设置移动方向
	_movement_input.x = 1.0 if _moving_right else -1.0

## 检查是否需要转向
func _should_turn() -> bool:
	# 获取角色当前位置
	var current_pos = controlled_character.global_position
	
	# 检查是否超出巡逻范围
	if abs(current_pos.x - _initial_position.x) > patrol_distance:
		return true
	
	# 检查前方是否有地面
	var space_state = controlled_character.get_world_2d().direct_space_state
	var check_pos = current_pos
	check_pos.x += edge_check_distance * signf(_movement_input.x)
	check_pos.y += 32  # 稍微向下偏移以检测地面
	
	var query = PhysicsRayQueryParameters2D.create(current_pos, check_pos)
	query.collision_mask = controlled_character.normal_mask
	
	var result = space_state.intersect_ray(query)
	return not result  # 如果没有检测到地面，则需要转向

## 重置巡逻
func reset_patrol() -> void:
	_initial_position = controlled_character.global_position
	_moving_right = true
