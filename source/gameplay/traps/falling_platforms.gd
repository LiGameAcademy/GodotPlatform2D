extends RigidBody2D

func _ready() -> void:
	CoreSystem.save_manager.register_saveable_node(self)

func _process(_delta: float) -> void:
	if global_position.y > 1000:
		freeze = true
		set_process(false)

func save() -> Dictionary:
	return {
		"freeze": freeze,
		"position": global_position,
	}

func load_data(platform_data: Dictionary) -> void:
	freeze = platform_data.get("freeze", false)
	global_position = platform_data.get("position", Vector2.ZERO)

func _on_body_entered(_body: Node) -> void:
	await get_tree().create_timer(0.5).timeout
	freeze = false
