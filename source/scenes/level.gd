extends Node2D
class_name Level

@onready var start_point: StartPoint = $StartPoint
@onready var end_point: EndPoint = $EndPoint
@onready var fruits_node: Node2D = $Fruits
@onready var traps_node: Node2D = $Traps

var _level_index: int
var _character : Character
var _score: int
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
	_score = data.get("score", 0)
	
	# 如果有缓存的关卡数据，加载它
	if not GameInstance.cached_level_data.is_empty():
		load_level_data(GameInstance.cached_level_data)
		GameInstance.cached_level_data = {}  # 清空缓存
	# 如果有保存的水果状态，加载它
	elif "fruits_state" in data:
		load_fruits_state(data.fruits_state)
	
	# 更新UI显示
	GameEvents.UIEvent.push_level_score_changed(_score)
	
	# 设置玩家
	_setup_player()

## 获取关卡数据
func get_level_data() -> Dictionary:
	return {
		"level_index": _level_index,
		"score": _score,
		"fruits_state": save_fruits_state()
	}

## 保存关卡数据 - 专用于存档系统
func save_level_data() -> Dictionary:
	return {
		"level_index": _level_index,
		"score": _score,
		"level_time": _level_time,
		"collected_fruits": collected_fruits.duplicate(),
		"passed_checkpoints": passed_checkpoints.duplicate(),
		"fruits_state": save_fruits_state()
	}

## 加载关卡数据 - 专用于存档系统
func load_level_data(data: Dictionary) -> void:
	_level_index = data.get("level_index", _level_index)
	_score = data.get("score", _score)
	_level_time = data.get("level_time", 0.0)
	collected_fruits = data.get("collected_fruits", []).duplicate()
	passed_checkpoints = data.get("passed_checkpoints", []).duplicate()
	
	if "fruits_state" in data:
		load_fruits_state(data.fruits_state)
	
	# 恢复检查点状态
	_restore_checkpoint_state()
	
	# 更新UI
	GameEvents.UIEvent.push_level_score_changed(_score)

## 完成关卡
func complete_level() -> void:
	# 保存分数
	GameInstance.add_level_score(_score)
	# 发送关卡完成事件
	GameEvents.LevelEvent.push_level_completed(_level_index, _score)
	# 自动保存游戏
	GameInstance.save_game()

## 重置关卡
func reset() -> void:
	_score = 0
	_level_time = 0.0
	collected_fruits.clear()
	passed_checkpoints.clear()
	GameEvents.UIEvent.push_level_score_changed(_score)

## 保存水果状态
func save_fruits_state() -> Array:
	var fruits_state = []
	if fruits_node:
		for fruit in fruits_node.get_children():
			if fruit is Fruit:
				# 如果水果被收集，记录它的ID
				if fruit.is_collected:
					var fruit_id = fruit.get_fruit_id() if fruit.has_method("get_fruit_id") else fruit.name
					collected_fruits.append(fruit_id)
				
				fruits_state.append({
					"name": fruit.name,
					"state": fruit.save_state()
				})
	return fruits_state

## 加载水果状态
func load_fruits_state(fruits_state: Array) -> void:
	if not fruits_node:
		return
		
	for fruit_data in fruits_state:
		var fruit_name = fruit_data.name
		var fruit_state = fruit_data.state
		# 使用 find_child 来查找水果节点，这样可以处理子节点的情况
		var fruit = fruits_node.find_child(fruit_name, true, false)
		if fruit and fruit is Fruit:
			fruit.load_state(fruit_state)
			
			# 如果水果ID在已收集列表中，确保它被标记为已收集
			var fruit_id = fruit.get_fruit_id() if fruit.has_method("get_fruit_id") else fruit.name
			if fruit_id in collected_fruits and not fruit.is_collected:
				fruit.collect()

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
	# 通知UI更新关卡分数
	GameEvents.UIEvent.push_level_score_changed(_score)

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
