extends PathFollow2D

@export var speed : float = 100
var _is_reversal : bool = false

func _process(delta: float) -> void:
	if not loop:
		if progress_ratio >= 0.99:
			_is_reversal = true
		elif progress_ratio <= 0.01:
			_is_reversal = false
	if _is_reversal:
		progress -= delta * speed
	else:
		progress += delta * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
