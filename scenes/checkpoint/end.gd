extends Node2D
class_name EndPoint

signal end

func _on_area_2d_body_entered(_body: Node2D) -> void:
	$AnimationPlayer.play("pressed")
	await $AnimationPlayer.animation_finished
	end.emit()
