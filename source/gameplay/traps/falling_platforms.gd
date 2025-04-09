extends RigidBody2D

func _ready() -> void:
	add_to_group("saveable")

func _process(_delta: float) -> void:
	if global_position.y > 1000:
		freeze = true
		set_process(false)

func save() -> PlatformData:
	var platform_data := PlatformData.new()
	platform_data.freeze = freeze
	return platform_data

func load_data(platform_data: PlatformData) -> void:
	freeze = platform_data.freeze

func _on_body_entered(_body: Node) -> void:
	await get_tree().create_timer(0.5).timeout
	freeze = false
