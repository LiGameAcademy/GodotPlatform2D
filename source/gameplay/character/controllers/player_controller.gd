# source/gameplay/character/controllers/player_controller.gd
extends CharacterController
class_name PlayerController

func get_movement_input() -> Vector2:
    var direction = Vector2.ZERO
    direction.x = Input.get_axis("move_left", "move_right")
    return direction

func get_jump_input() -> bool:
    return Input.is_action_just_pressed("jump")

func get_down_input() -> bool:
    return Input.is_action_pressed("move_down")