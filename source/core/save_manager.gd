extends Node

var save_manager : CoreSystem.SaveManager = CoreSystem.save_manager
var _current_save_id: String = ""

func _ready() -> void:	
	# 连接信号
	CoreSystem.event_bus.subscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)
	CoreSystem.save_manager.set_save_format("resource")

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)

func save_game() -> void:
	_current_save_id = save_manager.create_auto_save()

# 加载游戏
func load_game() -> bool:
	# 如果有当前存档，直接加载
	if not _current_save_id.is_empty():
		save_manager.load_save(_current_save_id)
	else:
		# 尝试加载最新的存档
		var saves : Array = await save_manager.get_save_list()
		if not saves.is_empty():
			_current_save_id = saves[0].id
			save_manager.load_save(_current_save_id)
	return true

# 检查是否有存档
func has_save() -> bool:
	var saves : Array = await save_manager.get_save_list()
	return not saves.is_empty()

# 自动存档（关卡完成时）
func _on_level_completed(_data) -> void:
	_current_save_id = save_manager.create_auto_save()