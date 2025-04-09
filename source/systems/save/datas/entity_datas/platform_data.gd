# source/systems/save/platform_state_data.gd
extends EntityData
class_name PlatformData

@export var platform_type: String = "normal"  # normal, moving, falling, etc.
@export var start_position: Vector2
@export var end_position: Vector2
@export var movement_progress: float = 0.0
@export var is_active: bool = true