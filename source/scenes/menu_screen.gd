extends Control
class_name MenuForm

@onready var settings_dialog = preload(ResourcePaths.UI.SETTINGS_DIALOG)
@onready var btn_continue: Button = %btn_continue

var _settings_instance: Window

func _ready() -> void:
	_settings_instance = settings_dialog.instantiate()
	add_child(_settings_instance)
	_settings_instance.hide()
	
	# 检查是否有存档，如果没有则隐藏继续按钮
	if not GameInstance.save_manager.has_save():
		btn_continue.hide()

func _on_btn_new_game_pressed() -> void:
	CoreSystem.event_bus.push_event("game_start_requested")

func _on_btn_continue_pressed() -> void:
	CoreSystem.event_bus.push_event("game_continue_requested")

func _on_btn_settings_pressed() -> void:
	_settings_instance.show()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
