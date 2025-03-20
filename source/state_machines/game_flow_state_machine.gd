extends BaseStateMachine
class_name GameFlowStateMachine

## 游戏流程状态机，管理游戏的所有状态转换

func _ready() -> void:
	# 创建并注册所有状态
	add_state(&"launch", LaunchState.new())
	add_state(&"menu", MenuState.new())
	add_state(&"character_select", CharacterSelectState.new())
	add_state(&"level_select", LevelSelectState.new())
	add_state(&"playing", PlayingState.new())
	

# 启动状态
class LaunchState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		switch_to(&"menu")


# 菜单状态
class MenuState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe("game_start_requested", _on_game_start_requested)
		GameInstance.show_menu_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe("game_start_requested", _on_game_start_requested)
	
	func _on_game_start_requested() -> void:
		switch_to(&"character_select")

# 角色选择状态
class CharacterSelectState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe("character_selected", _on_character_selected)
		CoreSystem.event_bus.subscribe("character_select_cancelled", _on_character_select_cancelled)
		GameInstance.show_character_select_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe("character_selected", _on_character_selected)
		CoreSystem.event_bus.unsubscribe("character_select_cancelled", _on_character_select_cancelled)
	
	func _on_character_selected() -> void:
		switch_to(&"level_select")
	
	func _on_character_select_cancelled() -> void:
		switch_to(&"menu")

# 关卡选择状态
class LevelSelectState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe("level_selected", _on_level_selected)
		CoreSystem.event_bus.subscribe("level_select_cancelled", _on_level_select_cancelled)
		GameInstance.show_level_select_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe("level_selected", _on_level_selected)
		CoreSystem.event_bus.unsubscribe("level_select_cancelled", _on_level_select_cancelled)
	
	func _on_level_selected(level_index: int) -> void:
		GameInstance.current_level = level_index
		switch_to(&"playing")
	
	func _on_level_select_cancelled() -> void:
		switch_to(&"character_select")

# 游戏进行状态
class PlayingState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe("level_completed", _on_level_completed)
		GameInstance.load_current_level()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe("level_completed", _on_level_completed)
	
	func _on_level_completed(level_index: int) -> void:
		# 标记当前关卡为已完成
		GameInstance.level_manager.completed_levels[level_index] = true
		
		# 检查是否是最后一关
		if level_index + 1 < GameInstance.level_manager.get_level_count():
			# 解锁下一关
			GameInstance.level_manager.unlocked_levels[level_index + 1] = true
			# 设置当前关卡并重新加载
			GameInstance.current_level = level_index + 1
			switch_to(&"playing")
		else:
			# 如果是最后一关，返回关卡选择界面
			switch_to(&"level_select")
