extends Node
class_name GameSaveManager

func _ready() -> void:	
	# 连接信号
	CoreSystem.event_bus.subscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)

# 自动存档（关卡完成时）
func _on_level_completed(_data) -> void:
	SaveSystem.create_auto_save()

func save_game() -> void:
	SaveSystem.create_auto_save()

# 加载游戏
func load_game() -> bool:
	# 如果有当前存档，直接加载
	if SaveSystem.get_current_save_id():
		SaveSystem.load_save(SaveSystem.get_current_save_id())
	else:
		# 尝试加载最新的存档
		var saves = SaveSystem.get_save_list()
		if not saves.is_empty():
			SaveSystem.load_save(saves[0].id)
	return true

# 检查是否有存档
func has_save() -> bool:
	return SaveSystem.has_save()
