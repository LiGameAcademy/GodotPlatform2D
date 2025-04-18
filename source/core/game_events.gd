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
