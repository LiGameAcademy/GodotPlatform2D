extends RigidBody2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# 控制旋转角度，避免跷跷板过度旋转
	var angle = rad_to_deg(state.transform.get_rotation())
	if angle > 30:  # 限制最大旋转到30度
		state.angular_velocity = max(state.angular_velocity, 0)
	elif angle < -30:  # 限制最小旋转到-30度
		state.angular_velocity = min(state.angular_velocity, 0)
