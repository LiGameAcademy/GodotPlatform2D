# source/systems/save/enemy_state_data.gd
extends EntityData
class_name EnemyData

@export var enemy_type: String = ""
@export var health: int = 1
@export var patrol_points: Array[Vector2] = []
@export var current_patrol_index: int = 0
@export var is_active: bool = true