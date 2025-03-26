extends Node2D
class_name Level

@onready var start_point: StartPoint = %StartPoint
@onready var end_point: EndPoint = %EndPoint

var _level_index: int
var _character : Character
var _score: int

	
func _ready() -> void:
	# 连接结束点信号
	if end_point:
		end_point.end.connect(_on_level_end)

func init_state(data: Dictionary) -> void:
	_level_index = data.level_index
	_score = data.score
	if not is_node_ready():
		await ready
	_setup_player()

func _setup_player() -> void:
	var character_scene : PackedScene = ResourcePaths.Characters.get_by_index(GameInstance.selected_character_index)
	if not character_scene:
		return
	_character = character_scene.instantiate()
	var player_controller : PlayerController = PlayerController.new()
	_character.add_child(player_controller)
	add_child(_character)
	_character.global_position = start_point.global_position
	
	# 订阅角色相关事件
	CoreSystem.event_bus.subscribe("character_death_animation_finished", _on_death_animation_finished, CoreSystem.event_bus.Priority.NORMAL,
		false, func(payload): return payload[0] == _character)
	
	# 启动起点动画
	start_point.start()

## 增加分数
func add_score(value: int) -> void:
	_score += value
	GameInstance.add_score(value)

## 完成关卡
func complete_level() -> void:
	# 保存分数
	GameInstance.score = _score
	# 发送关卡完成信号
	CoreSystem.event_bus.push_event("level_completed", _level_index)
	
## 死亡动画完成后处理
func _on_death_animation_finished(_character: Character) -> void:
	_setup_player()

## 关卡结束
func _on_level_end() -> void:
	complete_level()
	# 添加关卡结束的处理方法
	print("关卡结束")
