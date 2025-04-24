@tool
extends PathFollow2D

@export var speed : float = 100
@export var is_editor_hint : bool = false
var _is_reversal : bool = false

func _ready() -> void:
	$Sprite2D.play(&"on")

func _process(delta: float) -> void:
	if is_editor_hint and Engine.is_editor_hint():
		return
	if loop:
		progress += delta * speed
	else:
		if _is_reversal:
			progress -= delta * speed
			if progress_ratio <= 0.01:
				_is_reversal = false
		else:
			progress += delta * speed
			if progress_ratio >= 0.99:
				_is_reversal = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
