extends Node2D
class_name Level

@onready var start_point: StartPoint = $StartPoint
@onready var end_point: EndPoint = $EndPoint

var _level_index: int
var _character : Character
var _score: int
	
func _ready() -> void:
	# 连接结束点信号
	if end_point:
		end_point.end.connect(_on_level_end)
	CoreSystem.event_bus.subscribe(GameEvents.CollectionEvent.SCORE_CHANGED, _on_score_changed)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe(GameEvents.CollectionEvent.SCORE_CHANGED, _on_score_changed)

func init_state(data: Dictionary) -> void:
	_level_index = data.level_index
	# _score = data.score
	if not is_node_ready():
		await ready
	_setup_player()

func get_score() -> int:
	return _score

## 完成关卡
func complete_level() -> void:
	# 保存分数
	GameInstance.add_level_score(_score)
	# 发送关卡完成事件
	GameEvents.LevelEvent.push_level_completed(_level_index, _score)
	# 自动保存游戏
	GameInstance.save_game()

## 设置关卡索引
func set_level_index(index: int) -> void:
	_level_index = index

## 重置关卡
func reset() -> void:
	_score = 0
	GameEvents.UIEvent.push_level_score_changed(_score)

func _setup_player() -> void:
	_character = GameInstance.create_player_character()
	if not _character:
		CoreSystem.logger.error("Failed to create player character")
		return
		
	add_child(_character)
	_character.global_position = start_point.global_position
	
	# 订阅角色相关事件
	CoreSystem.event_bus.subscribe("character_death_animation_finished", _on_death_animation_finished, CoreSystem.event_bus.Priority.NORMAL,
		false, func(payload): return payload[0] == _character)
	
	# 启动起点动画
	start_point.start()

## 处理分数改变事件
func _on_score_changed(event_data: GameEvents.CollectionEvent.ScoreChangedData) -> void:
	_score += event_data.score
	# 通知UI更新关卡分数
	GameEvents.UIEvent.push_level_score_changed(_score)

## 死亡动画完成后处理
func _on_death_animation_finished(_cha: Character) -> void:
	_setup_player()

## 关卡结束
func _on_level_end() -> void:
	complete_level()
	# 添加关卡结束的处理方法
	print("关卡结束")
