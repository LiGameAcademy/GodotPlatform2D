# source/systems/save/character_state_data.gd
extends EntityStateData
class_name CharacterStateData

@export var velocity: Vector2
@export var can_double_jump: bool = true
@export var health: int = 3
@export var current_animation: String = "idle"
@export var facing_direction: int = 1  # 1 = 右, -1 = 左