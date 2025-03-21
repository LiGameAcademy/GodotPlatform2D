extends Control

@onready var btn_previous := $MarginContainer/HBoxContainer/btn_previous
@onready var btn_restart := $MarginContainer/HBoxContainer/btn_restart
@onready var btn_next := $MarginContainer/HBoxContainer/btn_next

func _ready() -> void:
	# 订阅关卡变化事件
	GameInstance.level_manager.level_changed.connect(_on_level_changed)
	# 初始化按钮状态
	_update_button_states()

func _exit_tree() -> void:
	if GameInstance.level_manager:
		GameInstance.level_manager.level_changed.disconnect(_on_level_changed)

func _on_level_changed(_old_level: int, _new_level: int) -> void:
	_update_button_states()

func _update_button_states() -> void:
	var current_index := GameInstance.level_manager.current_level_index
	var level_count := GameInstance.level_manager.get_level_count()
	
	# 上一关按钮：当前不是第一关就可用
	btn_previous.disabled = current_index <= 0
	
	# 重新开始按钮：总是可用
	btn_restart.disabled = false
	
	# 下一关按钮：不是最后一关，且下一关已解锁时可用
	btn_next.disabled = current_index >= level_count - 1 or \
		not GameInstance.level_manager.is_level_unlocked(current_index + 1)

func _on_btn_previous_pressed() -> void:
	CoreSystem.event_bus.push_event("level_previous_requested")

func _on_btn_restart_pressed() -> void:
	CoreSystem.event_bus.push_event("level_restart_requested")

func _on_btn_next_pressed() -> void:
	CoreSystem.event_bus.push_event("level_next_requested")

func _on_btn_settings_pressed() -> void:
	# CoreSystem.event_bus.push_event("settings_requested")
	pass
