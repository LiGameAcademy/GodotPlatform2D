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

func _exit_tree() -> void:
	if _character and _character.get_parent() == self:
		remove_child(_character)

func init_state(data: Dictionary) -> void:
	_level_index = data.level_index
	_character = data.character
	_score = data.score
	if not is_node_ready():
		await ready
	_setup_player()

func _setup_player() -> void:
	_character.set_process(false)
	add_child(_character)
	_character.global_position = start_point.global_position
	await get_tree().create_timer(0.3).timeout
	_character.set_process(true)
	
	# 连接死亡信号
	_character.died.connect(_on_player_died)
	
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
	
## 游戏失败
func _on_player_died() -> void:
	CoreSystem.event_bus.push_event("player_died")

## 关卡结束
func _on_level_end() -> void:
	complete_level()
	# 添加关卡结束的处理方法
	print("关卡结束")
