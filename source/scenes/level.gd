extends Node2D
class_name Level

@onready var start_point: StartPoint = $StartPoint
@onready var end_point: EndPoint = $EndPoint
@onready var fruits_node: Node2D = $Fruits
@onready var traps_node: Node2D = $Traps

var _level_index: int
var _character : Character
var _score: int:
	set(value):
		_score = value
		GameEvents.UIEvent.push_level_score_changed(_score)
var _level_time := 0.0
var collected_fruits := []
var passed_checkpoints := []

func _ready() -> void:
	# 连接结束点信号
	if end_point:
		end_point.end.connect(_on_level_end)
	CoreSystem.event_bus.subscribe(GameEvents.CollectionEvent.SCORE_CHANGED, _on_score_changed)

func _exit_tree() -> void:
	CoreSystem.event_bus.unsubscribe(GameEvents.CollectionEvent.SCORE_CHANGED, _on_score_changed)

func _process(delta: float) -> void:
	if not get_tree().paused:
		_level_time += delta

## 初始化关卡状态
func init_state(data: Dictionary) -> void:
	if not is_node_ready():
		await ready
	
	_level_index = data.get("level_index", 0)

	# 设置玩家
	_setup_player()
	
	# 初始化分数
	await get_tree().process_frame
	_score = data.get("score", 0)

## 完成关卡
func complete_level() -> void:
	# 保存分数
	GameInstance.add_level_score(_score)
	# 发送关卡完成事件
	GameEvents.LevelEvent.push_level_completed(_level_index, _score)

## 重置关卡
func reset() -> void:
	_score = 0
	_level_time = 0.0
	collected_fruits.clear()
	passed_checkpoints.clear()

# 恢复检查点状态
func _restore_checkpoint_state() -> void:
	var last_checkpoint = null
	var checkpoints = get_tree().get_nodes_in_group("checkpoints")
	
	for checkpoint in checkpoints:
		if checkpoint.has_method("get_checkpoint_id"):
			var cp_id = checkpoint.get_checkpoint_id()
			if cp_id in passed_checkpoints:
				checkpoint.activate()
				last_checkpoint = checkpoint
	
	# 如果有通过的检查点，更新起始位置
	if last_checkpoint:
		start_point = last_checkpoint

## 获取当前分数
func get_score() -> int:
	return _score

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

## 死亡动画完成后处理
func _on_death_animation_finished(_cha: Character) -> void:
	_setup_player()

## 关卡结束
func _on_level_end() -> void:
	complete_level()

## 记录检查点通过
func record_checkpoint(checkpoint_id: String) -> void:
	if not checkpoint_id in passed_checkpoints:
		passed_checkpoints.append(checkpoint_id)
		# 自动保存游戏，实现检查点功能
		GameInstance.quick_save()
