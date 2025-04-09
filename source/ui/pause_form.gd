extends Control

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var menu_button = $Panel/VBoxContainer/MenuButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume_button_pressed()

# 使用状态机变量来触发状态转换
func _on_resume_button_pressed() -> void:
	GameInstance.resume_game()
	queue_free()

func _on_menu_button_pressed() -> void:
	GameInstance.return_to_menu()
	queue_free()
