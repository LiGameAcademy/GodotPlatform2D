extends Control
class_name MenuForm


func _on_btn_new_game_pressed() -> void:
	CoreSystem.event_bus.push_event("game_start_requested")


func _on_btn_settings_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
