extends Control
class_name MenuForm

@onready var settings_dialog = preload(ResourcePaths.UI.SETTINGS_DIALOG)
var _settings_instance: Window

func _ready() -> void:
	# 创建设置弹窗实例
	_settings_instance = settings_dialog.instantiate()
	add_child(_settings_instance)
	_settings_instance.hide()

func _on_btn_new_game_pressed() -> void:
	CoreSystem.event_bus.push_event("game_start_requested")

func _on_btn_settings_pressed() -> void:
	_settings_instance.show()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
