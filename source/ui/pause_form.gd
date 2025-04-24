extends Control

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 暂停游戏
	# get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume_button_pressed()

# 使用状态机变量来触发状态转换
func _on_resume_button_pressed() -> void:
	hide()
	GameInstance.resume_game()

func _on_save_button_pressed() -> void:
	# 保存游戏
	GameInstance.save_manager.save_game()
	# 显示保存成功提示
	var label = $MarginContainer/MarginContainer/VBoxContainer/Label
	label.text = "Game Saved!"
	await get_tree().create_timer(1.0).timeout
	label.text = "PAUSED"

func _on_settings_button_pressed() -> void:
	# TODO: 实现设置功能
	pass # Replace with function body.

func _on_menu_button_pressed() -> void:
	hide()
	GameInstance.resume_game()
	GameInstance.return_to_menu()
