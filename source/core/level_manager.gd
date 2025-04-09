extends Node
class_name LevelManager

# 信号
signal level_changed(old_level: int, new_level: int)
signal level_started(level_index: int)

# 关卡配置
const LEVELS : Array[String] = ResourcePaths.ScenePaths.LEVELS

## 关卡数据
var current_level_index: int = 0:
	set(value):
		var old_index = current_level_index
		current_level_index = clampi(value, 0, LEVELS.size() - 1)
		if old_index != current_level_index:
			level_changed.emit(old_index, current_level_index)

var _current_level : Level:
	get:
		return get_tree().current_scene

## 关卡状态记录
var completed_levels: Array[bool] = []
var unlocked_levels: Array[bool] = []

func _ready() -> void:
	CoreSystem.scene_manager.register_transition(
		CoreSystem.scene_manager.TransitionEffect.CUSTOM, 
		LevelTransition.new(), 
		"level_transition"
	)
	
	# 初始化关卡状态数组
	completed_levels.resize(LEVELS.size())
	completed_levels.fill(false)
	
	unlocked_levels.resize(LEVELS.size())
	unlocked_levels.fill(false)
	unlocked_levels[0] = true  # 第一关默认解锁

## 创建关卡（用于预览）
func create_level_preview(level_index: int) -> Level:
	var level_scene : PackedScene = load(LEVELS[level_index])
	var level : Level = level_scene.instantiate()
	return level

## 加载下一关
func load_next_level() -> void:
	if current_level_index < LEVELS.size() - 1 and is_level_unlocked(current_level_index + 1):
		current_level_index += 1
		_load_level(LEVELS[current_level_index])

## 加载上一关
func load_previous_level() -> void:
	if current_level_index > 0:
		current_level_index -= 1
		_load_level(LEVELS[current_level_index])

## 加载指定关卡
func load_level(level_index: int) -> void:
	if level_index >= 0 and level_index < LEVELS.size() and is_level_unlocked(level_index):
		current_level_index = level_index
		_load_level(LEVELS[level_index])

## 关卡状态查询
func is_level_completed(level_index: int) -> bool:
	return level_index >= 0 and level_index < completed_levels.size() and completed_levels[level_index]

func is_level_unlocked(level_index: int) -> bool:
	return level_index >= 0 and level_index < unlocked_levels.size() and unlocked_levels[level_index]

func get_level_count() -> int:
	return LEVELS.size()

func get_level_path(level_index: int) -> String:
	if level_index >= 0 and level_index < LEVELS.size():
		return LEVELS[level_index]
	return ""

func get_current_level() -> Level:
	return _current_level

## 数据持久化
func save() -> LevelData:
	var level_data := LevelData.new()
	
	level_data.completed_levels = completed_levels
	level_data.unlocked_levels = unlocked_levels
	level_data.level_index = current_level_index
	level_data.level_score = _current_level.get_score()
	return level_data

func load(data: LevelData) -> void:
	completed_levels = data.completed_levels
	unlocked_levels = data.unlocked_levels
	current_level_index = data.level_index
	_load_level(LEVELS[current_level_index], data.level_score)
	await level_started

## 重置游戏数据（新游戏时调用）
func reset() -> void:
	current_level_index = 0
	
	# 重置关卡状态
	completed_levels.fill(false)
	unlocked_levels.fill(false)
	unlocked_levels[0] = true  # 第一关默认解锁

## 内部加载关卡方法
func _load_level(level_path: String, score: int = 0) -> void:
	# 准备关卡初始化数据
	var init_data = {
		"level_index": current_level_index,
		"score": score
	}
	
	# 使用场景管理器异步切换场景
	CoreSystem.scene_manager.change_scene_async(
		level_path, 
		init_data,
		false, 
		CoreSystem.scene_manager.TransitionEffect.CUSTOM,
		0.5,
		func() -> void:
			# 发送关卡开始信号
			level_started.emit(current_level_index),
		"level_transition"
	)
	
