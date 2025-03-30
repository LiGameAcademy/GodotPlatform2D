extends Node2D
class_name Level

@onready var start_point: StartPoint = $StartPoint
@onready var end_point: EndPoint = $EndPoint
@onready var fruits_node: Node2D = $Fruits

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

## 初始化关卡状态
func init_state(data: Dictionary) -> void:
	if not is_node_ready():
		await ready
	
	_level_index = data.get("level_index", 0)
	_score = data.get("score", 0)
	
	# 如果有保存的水果状态，加载它
	if "fruits_state" in data:
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
	GameEvents.UIEvent.push_level_score_changed(_score)

## 保存水果状态
func save_fruits_state() -> Array:
	var fruits_state = []
	if fruits_node:
		for fruit in fruits_node.get_children():
			if fruit is Fruit:
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
