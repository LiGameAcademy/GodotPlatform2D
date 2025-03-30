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

var _current_level : Level
var _current_level_state: Dictionary  # 当前关卡的状态

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

## 保存当前关卡状态
func save_current_level_state() -> void:
	if _current_level:
		_current_level_state = _current_level.get_level_data()

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
func save_level_data() -> Dictionary:
	# 保存当前关卡状态
	save_current_level_state()
	
	return {
		"completed_levels": completed_levels,
		"unlocked_levels": unlocked_levels,
		"current_level_index": current_level_index,
		"current_level_state": _current_level_state
	}

## 重置游戏数据（新游戏时调用）
func reset_game_data() -> void:
	current_level_index = 0
	_current_level_state = {}
	
	# 重置关卡状态
	completed_levels.fill(false)
	unlocked_levels.fill(false)
	unlocked_levels[0] = true  # 第一关默认解锁

func load_level_data(data: Dictionary) -> void:
	for completed in data.get("completed_levels", []):
		completed_levels.append(completed)
	for unlocked in data.get("unlocked_levels", []):
		unlocked_levels.append(unlocked)
	if "current_level_index" in data:
		current_level_index = data.current_level_index
	if "current_level_state" in data:
		_current_level_state = data.current_level_state

## 内部加载关卡方法
func _load_level(level_path: String) -> void:
	# 准备关卡初始化数据
	var init_data = {
		"level_index": current_level_index,
		"score": 0
	}
	
	# 如果有保存的状态且是当前关卡，使用保存的状态
	if not _current_level_state.is_empty() and _current_level_state.get("level_index") == current_level_index:
		init_data = _current_level_state
	
	# 使用场景管理器异步切换场景
	CoreSystem.scene_manager.change_scene_async(
		level_path, 
		init_data,
		false, 
		CoreSystem.scene_manager.TransitionEffect.CUSTOM,
		0.5,
		func() -> void:
			_current_level = CoreSystem.scene_manager.get_current_scene(),
		"level_transition"
	)
	
	# 发送关卡开始信号
	emit_signal("level_started", current_level_index)
