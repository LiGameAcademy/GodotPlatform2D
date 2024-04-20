extends CharacterBody2D

enum DIRECTION{
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
}

@onready var _state_chart: StateChart = $StateChart

@export var speed = 220.0
@export var move_directions : Array[DIRECTION]
var move_index : int = 0
var move_direction = Vector2.ZERO  # 移动方向，这里默认向右

func _physics_process(delta: float) -> void:
	#if move_and_slide():
		#handle_collision(get_last_slide_collision())
	var collision : KinematicCollision2D = move_and_collide(move_direction.normalized() * speed * delta)
	if collision:
		handle_collision(collision)

func handle_collision(collision : KinematicCollision2D) -> void:
	#print(collision.get_normal())
	_state_chart.set_meta("collision", collision)
	_state_chart.send_event("to_hit")

func handle_hit(collision : KinematicCollision2D) -> void:
	var _direction : Vector2 = collision.get_normal()
	for body in $Area2D.get_overlapping_bodies():
		if not body.has_method("die") : continue
		if _direction == Vector2.UP and body.global_position.y > global_position.y :
			body.call("die")
		elif _direction == Vector2.DOWN and body.global_position.y < global_position.y :
			body.call("die")
		elif _direction == Vector2.LEFT and body.global_position.x > global_position.x :
			body.call("die")
		elif _direction == Vector2.RIGHT and body.global_position.x < global_position.x :
			body.call("die")

func _on_idle_state_entered() -> void:
	$AnimationPlayer.play("blink")

func _on_move_state_entered() -> void:
	if move_directions.is_empty() : return
	var _direction : DIRECTION = move_directions[move_index]
	if _direction == DIRECTION.TOP:
		move_direction.y -= speed
		#velocity.y -= speed
	elif  _direction == DIRECTION.BOTTOM:
		move_direction.y += speed
		#velocity.y += speed
	elif  _direction == DIRECTION.LEFT:
		move_direction.x -= speed	
		#velocity.x -= speed	
	elif  _direction == DIRECTION.RIGHT:
		move_direction.x += speed
		#velocity.x += speed

func _on_move_state_exited() -> void:
	move_index = move_index + 1 if move_index < move_directions.size() -1 else 0
	move_direction = Vector2.ZERO

func _on_hit_state_entered() -> void:
	var collision : KinematicCollision2D = _state_chart.get_meta("collision")
	var _direction : Vector2 = collision.get_normal()
	if _direction == Vector2.UP:
		$AnimationPlayer.play("top_hit")
	elif _direction == Vector2.DOWN:
		$AnimationPlayer.play("bottom_hit")
	elif _direction == Vector2.LEFT:
		$AnimationPlayer.play("left_hit")
	elif _direction == Vector2.RIGHT:
		$AnimationPlayer.play("right_hit")
	handle_hit(collision)
	await $AnimationPlayer.animation_finished
	_state_chart.send_event("to_idle")
