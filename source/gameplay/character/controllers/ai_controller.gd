# source/gameplay/character/controllers/ai_controller.gd
extends CharacterController
class_name AIController

enum AIBehavior { PATROL, CHASE, ATTACK }

@export var detection_range := 200.0
@export var patrol_points: Array[Vector2]
var current_behavior := AIBehavior.PATROL
var target: Node2D
var current_patrol_index := 0

func update(delta: float) -> void:
    match current_behavior:
        AIBehavior.PATROL:
            _update_patrol()
        AIBehavior.CHASE:
            _update_chase()
        AIBehavior.ATTACK:
            _update_attack()

func get_movement_input() -> Vector2:
    var direction = Vector2.ZERO
    match current_behavior:
        AIBehavior.PATROL:
            direction = _get_patrol_direction()
        AIBehavior.CHASE:
            direction = _get_chase_direction()
    return direction.normalized()

# AI行为实现...
func _update_patrol() -> void:
    if target and _is_target_in_range():
        current_behavior = AIBehavior.CHASE

func _get_patrol_direction() -> Vector2:
    if patrol_points.is_empty():
        return Vector2.ZERO
    var target_point = patrol_points[current_patrol_index]
    return (target_point - character.global_position)