extends Node
class_name EffectManager


## 订阅事件
func _ready() -> void:
	CoreSystem.event_bus.subscribe(GameEvents.CollectionEvent.SCORE_CHANGED, _on_score_changed)

## 创建漂字效果
func create_floating_score(position: Vector2, score: int, combo: int = 1) -> void:
	var floating_score = load(ResourcePaths.Effects.FLOATING_SCORE).instantiate()
	var current_scene = CoreSystem.scene_manager.get_current_scene()
	current_scene.add_child(floating_score)
	floating_score.global_position = position
	floating_score.start(score, combo)

## 处理分数改变事件
func _on_score_changed(event_data: GameEvents.CollectionEvent.ScoreChangedData) -> void:
	create_floating_score(
		event_data.position,
		event_data.score,
		event_data.combo
	)
