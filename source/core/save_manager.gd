# source/core/save_manager.gd
extends Node
class_name SaveManager

var save_system: SaveSystem
var screenshot_capture: ScreenshotCapture

func _ready() -> void:
	save_system = SaveSystem.new()
	add_child(save_system)
	
	# 截图捕获组件
	screenshot_capture = ScreenshotCapture.new()
	add_child(screenshot_capture)
	
	# 连接信号
	CoreSystem.event_bus.subscribe("level_completed", _on_level_completed)
	CoreSystem.event_bus.subscribe("quick_save_requested", _on_quick_save_requested)
	# CoreSystem.event_bus.subscribe("save_game_requested", _on_save_game_requested)
	# CoreSystem.event_bus.subscribe("load_game_requested", _on_load_game_requested)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe("level_completed", _on_level_completed)
	CoreSystem.event_bus.unsubscribe("quick_save_requested", _on_quick_save_requested)
	# CoreSystem.event_bus.unsubscribe("save_game_requested", _on_save_game_requested)
	# CoreSystem.event_bus.unsubscribe("load_game_requested", _on_load_game_requested)

# 自动存档（关卡完成时）
func _on_level_completed(_data) -> void:
	var screenshot = await screenshot_capture.capture_game_screen()
	save_system.create_auto_save(screenshot)

# 快速存档（直接保存）
func _on_quick_save_requested() -> void:
	var screenshot = await screenshot_capture.capture_game_screen()
	save_system.create_quick_save(screenshot)
	
	# 显示保存成功提示
	GameEvents.UIEvent.push_notification("游戏已保存")

# 保存游戏
func save_game(save_slot := -1) -> void:
	var screenshot = await screenshot_capture.capture_game_screen()
	save_system.create_quick_save(screenshot)

# 加载游戏
func load_game(save_slot := -1) -> bool:
	# 如果有当前存档，直接加载
	if save_system.get_current_save_id():
		save_system.load_save(save_system.get_current_save_id())
	else:
		# 尝试加载最新的存档
		var saves = save_system.get_save_list()
		if not saves.is_empty():
			save_system.load_save(saves[0].id)
	return true

# 删除存档
func delete_save(save_slot := -1) -> void:
	var current_id = save_system.get_current_save_id()
	if not current_id.is_empty():
		save_system.delete_save(current_id)

# 检查是否有存档
func has_save() -> bool:
	return save_system.has_save()
