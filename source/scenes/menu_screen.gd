extends Control
class_name MenuForm

@onready var settings_dialog = preload(ResourcePaths.UI.SETTINGS_DIALOG)
@onready var btn_continue: Button = %btn_continue

var _settings_instance: Window

func _ready() -> void:
	# 创建设置弹窗实例
	_settings_instance = settings_dialog.instantiate()
	add_child(_settings_instance)
	_settings_instance.hide()
	
	# 检查是否存在存档
	_check_save_file()

func _check_save_file() -> void:
	# 检查存档文件是否存在
	if FileAccess.file_exists("user://save_data.json"):
		btn_continue.show()
	else:
		btn_continue.hide()

func _on_btn_new_game_pressed() -> void:
	CoreSystem.event_bus.push_event("game_start_requested")

func _on_btn_continue_pressed() -> void:
	CoreSystem.event_bus.push_event("game_continue_requested")

func _on_btn_settings_pressed() -> void:
	_settings_instance.show()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
