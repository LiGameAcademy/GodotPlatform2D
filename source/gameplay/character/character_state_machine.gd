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
		# 根据移动状态选择动画
		_update_ground_animation()
		_coyote_timer = 0.0
	
	func _physics_update(delta: float) -> void:
		if not agent.is_on_floor():
			_coyote_timer += delta
			if _coyote_timer > agent.coyote_time:
				switch_to(&"air")
		else:
			_coyote_timer = 0.0
			
		if agent.wants_to_jump():
			switch_to(&"air", {"jump": true})
		else:
			_update_ground_animation()
	
	## 更新地面动画
	func _update_ground_animation() -> void:
		var target_anim = "Idle" if not agent.is_moving() else "Move"
		if agent.current_animation != target_anim:
			agent.play_animation(target_anim)

# 空中状态（包含跳跃、二段跳和下落）
class AirState extends BaseState:
	var _was_double_jumping := false
	
	func _enter(msg: Dictionary = {}) -> void:
		_was_double_jumping = false
		if msg.get("jump", false):
			agent.velocity.y = agent.JUMP_VELOCITY
			CoreSystem.event_bus.push_event("jumped", agent)
			agent.play_animation("Move")
		else:
			# 如果不是从跳跃进入，保持当前动画状态
			if agent.current_animation == "Idle" or agent.current_animation == "":
				agent.play_animation("Move")
	
	func _physics_update(_delta: float) -> void:
		# 处理二段跳
		if agent.wants_to_jump():
			if agent.can_double_jump and not _was_double_jumping:
				_was_double_jumping = true
				agent.can_double_jump = false
				agent.velocity.y = agent.JUMP_VELOCITY * 0.8
				agent.play_animation("DoubleJump")
				CoreSystem.event_bus.push_event("jumped", agent)
			
		# 处理跳跃释放
		if agent.wants_to_jump_release() and agent.velocity.y < 0:
			agent.velocity.y *= agent.jump_cut_height
			
		# 处理状态转换
		if agent.is_on_floor():
			switch_to(&"ground")
		elif agent.is_on_wall() and agent.velocity.y > 0:
			switch_to(&"wall")
		elif not _was_double_jumping:
			# 只在非二段跳状态更新动画
			agent.play_animation("Move")

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
		elif agent.wants_to_jump():
			agent.velocity.y = agent.JUMP_VELOCITY
			agent.velocity.x = -signf(agent.get_node("Sprite2D").flip_h) * agent.SPEED
			CoreSystem.event_bus.push_event("jumped", agent)
			switch_to(&"air", {"jump": true})

# 死亡状态
class DeadState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		agent.play_animation("Desappearing")
		await agent.get_tree().create_timer(0.7).timeout
		if agent and agent.get_parent():
			# 从父节点移除
			agent.get_parent().remove_child(agent)
		# 发送动画完成事件
		CoreSystem.event_bus.push_event("character_death_animation_finished", agent)
