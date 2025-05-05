extends Node

## 角色相关事件
class CharacterEvent:
	const DIED := "character_died"
	const DEATH_ANIMATION_FINISHED := "character_death_animation_finished"
	
	## 角色死亡事件数据
	class CharacterDiedData:
		var character: Character
		var position: Vector2
		
		func _init(p_character: Character, p_position: Vector2) -> void:
			character = p_character
			position = p_position
	
	## 死亡动画完成事件数据
	class DeathAnimationFinishedData:
		var character: Character
		
		func _init(p_character: Character) -> void:
			character = p_character
	
	## 发送角色死亡事件
	static func push_died(character: Character, position: Vector2) -> void:
		CoreSystem.event_bus.push_event(DIED, CharacterDiedData.new(character, position))
	
	## 发送死亡动画完成事件
	static func push_death_animation_finished(character: Character) -> void:
		CoreSystem.event_bus.push_event(DEATH_ANIMATION_FINISHED, DeathAnimationFinishedData.new(character))

## 收集系统事件
class CollectionEvent:
	const FRUIT_COLLECTED := "fruit_collected"
	const COMBO_ENDED := "combo_ended"
	const SCORE_CHANGED := "score_changed"
	
	## 水果收集事件数据
	class FruitCollectedData:
		var collector: Character
		var fruit: Node2D
		var type: String
		var position: Vector2
		
		func _init(p_collector: Character, p_fruit: Node2D, p_type: String, p_position: Vector2) -> void:
			collector = p_collector
			fruit = p_fruit
			type = p_type
			position = p_position
	
	## 连击结束事件数据
	class ComboEndedData:
		var final_combo: int
		
		func _init(p_final_combo: int) -> void:
			final_combo = p_final_combo
	
	## 分数改变事件数据
	class ScoreChangedData:
		var score: int
		var combo: int
		var position: Vector2
		
		func _init(p_score: int, p_combo: int = 1, p_position: Vector2 = Vector2.ZERO) -> void:
			score = p_score
			combo = p_combo
			position = p_position
	
	## 发送水果收集事件
	static func push_fruit_collected(collector: Character, fruit: Node2D, type: String, position: Vector2) -> void:
		CoreSystem.event_bus.push_event(FRUIT_COLLECTED, FruitCollectedData.new(collector, fruit, type, position))
	
	## 发送连击结束事件
	static func push_combo_ended(final_combo: int) -> void:
		CoreSystem.event_bus.push_event(COMBO_ENDED, ComboEndedData.new(final_combo))
	
	## 发送分数改变事件
	static func push_score_changed(score: int, combo: int = 1, position: Vector2 = Vector2.ZERO) -> void:
		CoreSystem.event_bus.push_event(SCORE_CHANGED, ScoreChangedData.new(score, combo, position))

## 关卡事件
class LevelEvent:
	const LEVEL_COMPLETED := "level_completed"
	
	## 关卡完成事件数据
	class LevelCompletedData:
		var level_index: int
		var score: int
		
		func _init(p_level_index: int, p_score: int) -> void:
			level_index = p_level_index
			score = p_score
	
	## 发送关卡完成事件
	static func push_level_completed(level_index: int, score: int) -> void:
		CoreSystem.event_bus.push_event(LEVEL_COMPLETED, LevelCompletedData.new(level_index, score))

## UI事件
class UIEvent:
	const FLOATING_SCORE_SPAWNED := "floating_score_spawned"
	const LEVEL_SCORE_CHANGED := "level_score_changed"
	const TOTAL_SCORE_CHANGED := "total_score_changed"
	const NOTIFICATION := "notification"
	
	## 分数改变事件数据
	class ScoreData:
		var score: int
		
		func _init(p_score: int) -> void:
			score = p_score
	
	## 发送关卡分数改变事件
	static func push_level_score_changed(score: int) -> void:
		CoreSystem.event_bus.push_event(LEVEL_SCORE_CHANGED, ScoreData.new(score))
	
	## 发送总分数改变事件
	static func push_total_score_changed(score: int) -> void:
		CoreSystem.event_bus.push_event(TOTAL_SCORE_CHANGED, ScoreData.new(score))

	static func push_notification(message: String) -> void:
		CoreSystem.event_bus.push_event(NOTIFICATION, message)

## 游戏流程事件
class GameFlowEvent:
	const GAME_PAUSED := "game_paused"
	const GAME_RESUMED := "game_resumed"
	const EXIT_LEVEL := "exit_level"
	const EXIT_GAME := "exit_game"
	const GAME_START_REQUESTED := "game_start_requested"
	const GAME_CONTINUE_REQUESTED := "game_continue_requested"
	
	## 发送游戏暂停事件
	static func push_game_paused() -> void:
		CoreSystem.event_bus.push_event(GAME_PAUSED)
	
	## 发送游戏恢复事件
	static func push_game_resumed() -> void:
		CoreSystem.event_bus.push_event(GAME_RESUMED)
	
	## 发送退出关卡事件
	static func push_exit_level() -> void:
		CoreSystem.event_bus.push_event(EXIT_LEVEL)
	
	## 发送退出游戏事件
	static func push_exit_game() -> void:
		CoreSystem.event_bus.push_event(EXIT_GAME)

	## 发送开始新游戏请求事件
	static func push_game_start_requested() -> void:
		CoreSystem.event_bus.push_event(GAME_START_REQUESTED)
	
	## 发送继续游戏请求事件
	static func push_game_continue_requested() -> void:
		CoreSystem.event_bus.push_event(GAME_CONTINUE_REQUESTED)

## 角色选择事件
class CharacterSelectEvent:
	const CHARACTER_SELECTED := "character_selected"
	const CHARACTER_SELECT_CANCELLED := "character_select_cancelled"
	
	## 发送角色选择事件
	static func push_character_selected(character_index: int) -> void:
		CoreSystem.event_bus.push_event(CHARACTER_SELECTED, character_index)
	
	## 发送角色选择取消事件
	static func push_character_select_cancelled() -> void:
		CoreSystem.event_bus.push_event(CHARACTER_SELECT_CANCELLED)

## 关卡选择事件
class LevelSelectEvent:
	const LEVEL_SELECTED := "level_selected"
	const LEVEL_SELECT_CANCELLED := "level_select_cancelled"
	
	## 发送关卡选择事件
	static func push_level_selected(level_index: int) -> void:
		CoreSystem.event_bus.push_event(LEVEL_SELECTED, level_index)
	
	## 发送关卡选择取消事件
	static func push_level_select_cancelled() -> void:
		CoreSystem.event_bus.push_event(LEVEL_SELECT_CANCELLED)

## 存档系统事件
class SaveEvent:
	const SAVE_CREATED := "save_created"
	const SAVE_LOADED := "save_loaded"
	const SAVE_DELETED := "save_deleted"
	
	## 存档事件数据
	class SaveDataEvent:
		var save_index: int
		var save_name: String
		
		func _init(p_save_index: int, p_save_name: String = "") -> void:
			save_index = p_save_index
			save_name = p_save_name
	
	## 发送存档创建事件
	static func push_save_created(save_index: int, save_name: String = "") -> void:
		CoreSystem.event_bus.push_event(SAVE_CREATED, SaveDataEvent.new(save_index, save_name))
	
	## 发送存档加载事件
	static func push_save_loaded(save_index: int) -> void:
		CoreSystem.event_bus.push_event(SAVE_LOADED, SaveDataEvent.new(save_index))
	
	## 发送存档删除事件
	static func push_save_deleted(save_index: int) -> void:
		CoreSystem.event_bus.push_event(SAVE_DELETED, SaveDataEvent.new(save_index))
