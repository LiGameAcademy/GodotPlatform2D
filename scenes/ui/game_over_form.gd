extends Control

@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var retry_button = $Panel/VBoxContainer/RetryButton
@onready var menu_button = $Panel/VBoxContainer/MenuButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	# 显示最终分数
	score_label.text = "Score: %d" % GameInstance.score

# 使用状态机变量来触发状态转换
func _on_retry_button_pressed() -> void:
	GameInstance.retry_game()
	queue_free()

func _on_menu_button_pressed() -> void:
	GameInstance.return_to_menu()
	queue_free()
