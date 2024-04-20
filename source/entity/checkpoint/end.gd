extends Node2D

signal end

func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("pressed")
	await $AnimationPlayer.animation_finished
	end.emit()
