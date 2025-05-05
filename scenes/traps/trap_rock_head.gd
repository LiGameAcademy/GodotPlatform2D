extends CharacterBody2D

# 方向枚举
enum DIRECTION {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
}

# 碰撞类型枚举
enum COLLISION_TYPE {
	NONE,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
}

@export var speed = 220.0
@export var move_directions : Array[DIRECTION]
@export var hit_damage: int = 1
@export var debug_mode: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area2d: Area2D = $Area2D
var _move_index: int = 0

func _ready() -> void:
	_setup_state_machine()

func _exit_tree() -> void:
	CoreSystem.state_machine_manager.unregister_state_machine(&"rock_head_state_machine_%d" % get_instance_id())

func set_move_index() -> void:
	_move_index = _move_index + 1 if _move_index < move_directions.size() -1 else 0

func get_move_direction() -> DIRECTION:
	return move_directions[_move_index]

func _setup_state_machine() -> void:
	CoreSystem.state_machine_manager.register_state_machine(
		&"rock_head_state_machine_%d" % get_instance_id(),
		RockHeadStateMachine.new(),
		self,
		&"idle",
	)

class RockHeadStateMachine:
	extends BaseStateMachine

	func _ready() -> void:
		add_state(&"idle", IdleState.new())
		add_state(&"moving", MovingState.new())
		add_state(&"hitting", HittingState.new())
		
	class IdleState:
		extends BaseState

		func _enter(_msg: Dictionary = {}) -> void:
			agent.animation_player.play("blink")
			await agent.get_tree().create_timer(1.0).timeout
			switch_to(&"moving")
		
	class MovingState:
		extends BaseState

		var _direction : Vector2 = Vector2.ZERO

		func _enter(_msg: Dictionary = {}) -> void:
			if not agent:
				return
			if agent.move_directions.is_empty() : return
			var move_dir : DIRECTION = agent.get_move_direction()
			match move_dir:
				DIRECTION.TOP:
					_direction.y -= 1
				DIRECTION.BOTTOM:
					_direction.y += 1
				DIRECTION.LEFT:
					_direction.x -= 1
				DIRECTION.RIGHT:
					_direction.x += 1

		func _physics_update(delta: float) -> void:
			_move(delta)
		
		func _exit() -> void:
			agent.set_move_index()
			_direction = Vector2.ZERO

		func _move(delta: float) -> void:
			var velocity = _direction.normalized() * delta * agent.speed
			var collision : KinematicCollision2D = agent.move_and_collide(velocity)
			if collision:
				_handle_collision(collision)
			
		func _handle_collision(collision : KinematicCollision2D) -> void:
			var collision_type : COLLISION_TYPE = state_machine.get_collision_type(collision.get_normal())
			if agent.debug_mode:
				CoreSystem.logger.debug("Collision type: %s" % collision_type)
			if collision_type != COLLISION_TYPE.NONE:
				switch_to(&"hitting", {"collision": collision})
	
	class HittingState:
		extends BaseState

		var _last_collision : KinematicCollision2D = null

		func _enter(msg: Dictionary = {}) -> void:
			_last_collision = msg.get("collision", null)

			var collision_type = state_machine.get_collision_type(_last_collision.get_normal())
			var animation = _get_hit_animation(collision_type)
		
			if animation:
				agent.animation_player.play(animation)
				await agent.animation_player.animation_finished
				switch_to(&"idle")

		func _physics_update(_delta: float) -> void:
			_handle_hit()
		
		func _handle_hit() -> void:
			if not _last_collision:
				return

			for body in agent.area2d.get_overlapping_bodies():
				if not body.has_method("die"):
					continue
				body.call("die")

		func _get_hit_area(collision_type : COLLISION_TYPE) -> Vector2:
			match collision_type:
				COLLISION_TYPE.TOP:
					return Vector2.UP
				COLLISION_TYPE.BOTTOM:
					return Vector2.DOWN
				COLLISION_TYPE.LEFT:
					return Vector2.LEFT
				COLLISION_TYPE.RIGHT:
					return Vector2.RIGHT
				_:
					return Vector2.ZERO
		
		func _get_hit_animation(collision_type : COLLISION_TYPE) -> StringName:
			match collision_type:
				COLLISION_TYPE.TOP:
					return "bottom_hit"
				COLLISION_TYPE.BOTTOM:
					return "top_hit"
				COLLISION_TYPE.LEFT:
					return "right_hit"
				COLLISION_TYPE.RIGHT:
					return "left_hit"
				_:
					return ""

	func get_collision_type(normal : Vector2) -> COLLISION_TYPE:
		match normal:
			Vector2.UP:
				return COLLISION_TYPE.TOP
			Vector2.DOWN:
				return COLLISION_TYPE.BOTTOM
			Vector2.LEFT:
				return COLLISION_TYPE.LEFT
			Vector2.RIGHT:
				return COLLISION_TYPE.RIGHT
		return COLLISION_TYPE.NONE
