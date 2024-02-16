extends AnimationTree

var state_machine : AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	assert(owner is CharacterBody2D)
	var speed : float = abs(owner.velocity.x)
	set("parameters/StateMachine/idle_run/blend_position", speed)

	# 根据垂直速度切换动画状态
	if owner.velocity.y < 0:
		state_machine.travel("jump")
	elif owner.velocity.y > 0 and not owner.is_on_floor():
		state_machine.travel("fall")
	elif owner.is_on_floor():
		state_machine.travel("idle_run") # 如果有idle状态的话
