extends RigidBody2D

func _on_body_entered(_body: Node) -> void:
	await get_tree().create_timer(0.5).timeout
	freeze = false
