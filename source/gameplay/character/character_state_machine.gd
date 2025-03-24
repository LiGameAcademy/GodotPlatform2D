extends BaseStateMachine
class_name CharacterStateMachine

## 角色状态机，管理角色的所有状态转换和行为

func _ready() -> void:
	# 创建并注册所有状态
	add_state(&"ground", GroundState.new())
	add_state(&"air", AirState.new())
	add_state(&"wall", WallState.new())
	add_state(&"dead", DeadState.new())

	# 订阅死亡事件
	CoreSystem.event_bus.subscribe("character_died", _on_character_died, CoreSystem.event_bus.Priority.HIGH)

func _dispose() -> void:
	CoreSystem.event_bus.unsubscribe("character_died", _on_character_died)

func _on_character_died(character: Character) -> void:
	if character == agent:
		switch(&"dead")

# 地面状态（包含站立和移动）
class GroundState extends BaseState:
	var _coyote_timer: float = 0.0
	
	func _enter(_msg: Dictionary = {}) -> void:
		agent.can_double_jump = true
		agent.play_animation("Idle")
		_coyote_timer = 0.0
	
	func _physics_update(delta: float) -> void:
		if not agent.is_on_floor():
			_coyote_timer += delta
			if _coyote_timer > agent.coyote_time:
				switch_to(&"air")
		else:
			_coyote_timer = 0.0
			
		if agent.is_jumping():
			switch_to(&"air", {"jump": true})
		else:
			# 更新动画
			var anim = "Idle" if not agent.is_moving() else "Move"
			if agent.current_animation != anim:
				agent.play_animation(anim)

# 空中状态（包含跳跃、二段跳和下落）
class AirState extends BaseState:
	var _jump_buffer_timer: float = 0.0
	
	func _enter(msg: Dictionary = {}) -> void:
		if msg.get("jump", false):
			agent.velocity.y = agent.JUMP_VELOCITY
			agent.play_animation("Move") # 使用混合空间
		else:
			agent.play_animation("Move") # 使用混合空间
		_jump_buffer_timer = 0.0
	
	func _physics_update(delta: float) -> void:
		# 处理跳跃缓冲
		if agent.is_jumping():
			_jump_buffer_timer = agent.jump_buffer_time
		elif _jump_buffer_timer > 0:
			_jump_buffer_timer -= delta
			
		# 处理状态转换
		if agent.is_on_floor():
			if _jump_buffer_timer > 0:
				agent.velocity.y = agent.JUMP_VELOCITY
				_jump_buffer_timer = 0
			switch_to(&"ground")
		elif agent.is_on_wall() and agent.velocity.y > 0:
			switch_to(&"wall")
		elif agent.is_jumping() and agent.can_double_jump:
			agent.can_double_jump = false
			agent.velocity.y = agent.JUMP_VELOCITY * 0.8
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
		await agent.get_tree().create_timer(0.7).timeout
		# 从父节点移除
		agent.get_parent().remove_child(agent)
		# 发送动画完成事件
		CoreSystem.event_bus.push_event("character_death_animation_finished", agent)
