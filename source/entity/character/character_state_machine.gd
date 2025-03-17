extends BaseStateMachine
class_name CharacterStateMachine

## 角色状态机，管理角色的所有状态转换和行为

func _ready() -> void:
	super()
	# 创建并注册所有状态
	add_state(&"ground", GroundState.new())
	add_state(&"air", AirState.new())
	add_state(&"wall", WallState.new())
	add_state(&"dead", DeadState.new())


# 地面状态（包含站立和移动）
class GroundState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		agent.can_double_jump = true
		agent.play_animation("Idle")
	
	func _physics_update(_delta: float) -> void:
		if not agent.is_on_floor():
			switch_to(&"air")
		elif agent.is_jumping():
			switch_to(&"air", {"jump": true})
		else:
			# 更新动画
			var anim = "Idle" if not agent.is_moving() else "Move"
			if agent.current_animation != anim:
				agent.play_animation(anim)


# 空中状态（包含跳跃、二段跳和下落）
class AirState extends BaseState:
	func _enter(msg: Dictionary = {}) -> void:
		if msg.get("jump", false):
			agent.velocity.y = agent.JUMP_VELOCITY
			agent.play_animation("Move") # 使用混合空间
		else:
			agent.play_animation("Move") # 使用混合空间
	
	func _physics_update(_delta: float) -> void:
		if agent.is_on_floor():
			switch_to(&"ground")
		elif agent.is_on_wall() and agent.velocity.y > 0:
			switch_to(&"wall")
		elif agent.is_jumping() and agent.can_double_jump:
			agent.can_double_jump = false
			agent.velocity.y = agent.JUMP_VELOCITY
			agent.play_animation("DoubleJump")
		else:
			# 更新动画
			var anim = "Move" if agent.velocity.y < 0 else "Move"
			if agent.current_animation != anim:
				agent.play_animation(anim)


# 墙壁状态（包含墙壁滑行和墙跳）
class WallState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		agent.can_double_jump = true
		agent.play_animation("Walled")
	
	func _physics_update(_delta: float) -> void:
		# 限制下落速度
		if agent.velocity.y > 0:
			agent.velocity.y = min(agent.velocity.y, agent.wall_slide_speed)
		
		if agent.is_on_floor():
			switch_to(&"ground")
		elif not agent.is_on_wall():
			switch_to(&"air")
		elif agent.is_jumping():
			agent.velocity.y = agent.JUMP_VELOCITY
			agent.velocity.x = -signf(agent.get_node("Sprite2D").flip_h) * agent.SPEED
			switch_to(&"air", {"jump": true})


# 死亡状态
class DeadState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		agent.play_animation("Desappearing")
