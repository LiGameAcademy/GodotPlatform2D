# source/gameplay/character/controllers/character_controller.gd
extends Node
class_name CharacterController

var character: Character

func _init(controlled_character: Character) -> void:
    character = controlled_character

func update(delta: float) -> void:
    pass  # 由子类实现

# 提供角色控制的基本接口
func get_movement_input() -> Vector2:
    return Vector2.ZERO

func get_jump_input() -> bool:
    return false

func get_down_input() -> bool:
    return false