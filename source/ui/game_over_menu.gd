extends Control

@onready var score_label: Label = %ScoreLabel

func _ready() -> void:
	hide()
	CoreSystem.event_bus.subscribe("game_over", _on_game_over)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe("game_over", _on_game_over)

func _on_game_over() -> void:
	score_label.text = "Score: %d" % GameInstance.score
	show()

func _on_btn_retry_pressed() -> void:
	hide()
	CoreSystem.event_bus.push_event("retry_game")

func _on_btn_quit_pressed() -> void:
	hide()
	CoreSystem.event_bus.push_event("quit_to_menu")
