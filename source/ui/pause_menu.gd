extends Control

func _ready() -> void:
	hide()
	CoreSystem.event_bus.subscribe("pause_game", _on_pause_game)
	CoreSystem.event_bus.subscribe("resume_game", _on_resume_game)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe("pause_game", _on_pause_game)
	CoreSystem.event_bus.unsubscribe("resume_game", _on_resume_game)

func _on_pause_game() -> void:
	show()

func _on_resume_game() -> void:
	hide()

func _on_btn_resume_pressed() -> void:
	CoreSystem.event_bus.push_event("resume_game")

func _on_btn_retry_pressed() -> void:
	CoreSystem.event_bus.push_event("retry_game")

func _on_btn_quit_pressed() -> void:
	CoreSystem.event_bus.push_event("quit_to_menu")
