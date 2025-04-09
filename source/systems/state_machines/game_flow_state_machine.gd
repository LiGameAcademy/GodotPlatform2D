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
		CoreSystem.event_bus.subscribe(GameEvents.GameFlowEvent.GAME_START_REQUESTED, _on_game_start_requested)
		CoreSystem.event_bus.subscribe(GameEvents.GameFlowEvent.GAME_CONTINUE_REQUESTED, _on_game_continue_requested)
		GameInstance.show_menu_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe(GameEvents.GameFlowEvent.GAME_START_REQUESTED, _on_game_start_requested)
		CoreSystem.event_bus.unsubscribe(GameEvents.GameFlowEvent.GAME_CONTINUE_REQUESTED, _on_game_continue_requested)
	
	func _on_game_start_requested() -> void:
		GameInstance.start_new_game()
		switch_to(&"character_select")
	
	func _on_game_continue_requested() -> void:
		GameInstance.continue_game()
		switch_to(&"playing")

# 角色选择状态
class CharacterSelectState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe(GameEvents.CharacterSelectEvent.CHARACTER_SELECTED, _on_character_selected)
		CoreSystem.event_bus.subscribe(GameEvents.CharacterSelectEvent.CHARACTER_SELECT_CANCELLED, _on_character_select_cancelled)
		GameInstance.show_character_select_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe(GameEvents.CharacterSelectEvent.CHARACTER_SELECTED, _on_character_selected)
		CoreSystem.event_bus.unsubscribe(GameEvents.CharacterSelectEvent.CHARACTER_SELECT_CANCELLED, _on_character_select_cancelled)
	
	func _on_character_selected() -> void:
		switch_to(&"level_select")
	
	func _on_character_select_cancelled() -> void:
		switch_to(&"menu")

# 关卡选择状态
class LevelSelectState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe(GameEvents.LevelSelectEvent.LEVEL_SELECTED, _on_level_selected)
		CoreSystem.event_bus.subscribe(GameEvents.LevelSelectEvent.LEVEL_SELECT_CANCELLED, _on_level_select_cancelled)
		GameInstance.show_level_select_scene()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe(GameEvents.LevelSelectEvent.LEVEL_SELECTED, _on_level_selected)
		CoreSystem.event_bus.unsubscribe(GameEvents.LevelSelectEvent.LEVEL_SELECT_CANCELLED, _on_level_select_cancelled)
	
	func _on_level_selected(level_index: int) -> void:
		GameInstance.current_level = level_index
		switch_to(&"playing")
	
	func _on_level_select_cancelled() -> void:
		switch_to(&"character_select")

# 游戏进行状态
class PlayingState extends BaseState:
	func _enter(_msg: Dictionary = {}) -> void:
		CoreSystem.event_bus.subscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)
		CoreSystem.event_bus.subscribe("level_previous_requested", _on_level_previous_requested)
		CoreSystem.event_bus.subscribe("level_restart_requested", _on_level_restart_requested)
		CoreSystem.event_bus.subscribe("level_next_requested", _on_level_next_requested)
		CoreSystem.event_bus.subscribe("game_exit_requested", _on_game_exit_requested)
		GameInstance.load_current_level()
	
	func _exit() -> void:
		CoreSystem.event_bus.unsubscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)
		CoreSystem.event_bus.unsubscribe("level_previous_requested", _on_level_previous_requested)
		CoreSystem.event_bus.unsubscribe("level_restart_requested", _on_level_restart_requested)
		CoreSystem.event_bus.unsubscribe("level_next_requested", _on_level_next_requested)
		CoreSystem.event_bus.unsubscribe("game_exit_requested", _on_game_exit_requested)
	
	func _on_level_completed(event_data : GameEvents.LevelEvent.LevelCompletedData) -> void:
		# 标记当前关卡为已完成
		GameInstance.level_manager.completed_levels[event_data.level_index] = true
		
		# 自动保存游戏
		GameInstance.save_game()
		
		# 检查是否是最后一关
		if event_data.level_index + 1 < GameInstance.level_manager.get_level_count():
			# 解锁下一关
			GameInstance.level_manager.unlocked_levels[event_data.level_index + 1] = true
			# 设置当前关卡并重新加载
			GameInstance.current_level = event_data.level_index + 1
			switch_to(&"playing")
		else:
			# 如果是最后一关，返回关卡选择界面
			switch_to(&"level_select")
	
	func _on_level_previous_requested() -> void:
		GameInstance.level_manager.load_previous_level()
	
	func _on_level_restart_requested() -> void:
		GameInstance.load_current_level()
	
	func _on_level_next_requested() -> void:
		GameInstance.level_manager.load_next_level()
	
	func _on_game_exit_requested() -> void:
		# 保存游戏
		GameInstance.save_game()
		# 切换到菜单状态
		switch_to(&"menu")
