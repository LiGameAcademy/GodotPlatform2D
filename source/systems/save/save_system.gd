extends Node

signal save_created(save_id: String, metadata: Dictionary)
signal save_loaded(save_id: String, metadata: Dictionary)
signal save_deleted(save_id: String)
signal auto_save_created(save_id: String)

const SAVE_DIR = "user://saves/"
const AUTO_SAVE_PREFIX = "auto_"
const QUICK_SAVE_PREFIX = "quick_"
const MAX_AUTO_SAVES = 3
const SAVE_EXTENSION = ".tres"

var _current_save_id: String = ""

func _init() -> void:
	# 确保存档目录存在
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# 创建存档（支持自定义ID或自动生成）
func create_save(save_id: String = "") -> String:
	var actual_id = save_id
	if actual_id.is_empty():
		actual_id = _generate_save_id()
	
	# 创建游戏状态数据
	var game_data : GameData = GameInstance.save()
	
	# 创建关卡状态数据
	var level_data : LevelData = GameInstance.level_manager.save()
	
	# 收集实体状态
	var entity_datas: Array[EntityData] = []
	var saveables = get_tree().get_nodes_in_group("saveable")
	for saveable in saveables:
		var entity_data : EntityData = saveable.save()
		entity_data.node_path = saveable.get_path()
		entity_data.position = saveable.global_position
		entity_datas.append(entity_data)
	
	# 设置存档数据
	var save_data := SaveData.new(
		actual_id,
		Time.get_unix_time_from_system() as int,
		Time.get_datetime_string_from_system(),
		ProjectSettings.get_setting("application/config/version", "1.0.0"),
		0.0,
		game_data,
		level_data,
		entity_datas
	)

	# 保存数据到文件
	var save_path = _get_save_path(actual_id)
	var error = ResourceSaver.save(save_data, save_path)
	
	if error == OK:
		_current_save_id = actual_id
		save_created.emit(actual_id, save_data)
	else:
		push_error("保存游戏失败: " + str(error))
	
	return actual_id

# 加载存档
func load_save(save_id: String = "") -> bool:
	var save_path = _get_save_path(save_id)
	
	if not FileAccess.file_exists(save_path):
		push_error("存档文件不存在: " + save_path)
		return false
	
	var save_data : SaveData = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if not save_data is SaveData:
		push_error("无效的存档数据")
		return false
	
	# 加载游戏状态
	GameInstance.load(save_data.game_state)
	
	# 加载关卡状态
	await GameInstance.level_manager.load(save_data.level_state)
	
	# 加载实体状态
	# 注意：实体状态通常在关卡加载后应用
	_load_entity_states(save_data)
	
	_current_save_id = save_id
	save_loaded.emit(save_id, save_data)
	return true

# 创建自动存档
func create_auto_save() -> String:
	var auto_save_id = AUTO_SAVE_PREFIX + _get_timestamp()
	var save_id = create_save(auto_save_id)

	auto_save_created.emit(save_id)
	return save_id

# 创建快速存档
func create_quick_save() -> String:
	var quick_save_id = QUICK_SAVE_PREFIX + _get_timestamp()
	return create_save(quick_save_id)

# 获取所有存档列表
func get_save_list() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while not file_name.is_empty():
			if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
				var save_id = file_name.get_basename()
				var save_path = _get_save_path(save_id)
				
				# 加载存档元数据
				var save_data = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
				if save_data is SaveData:
					saves.append({
						"id": save_id,
						"save_data": save_data
					})
			
			file_name = dir.get_next()
	
	# 按时间戳排序，最新的在前面
	saves.sort_custom(func(a, b): return a.save_data.timestamp > b.save_data.timestamp)
	
	return saves

# 删除存档
func delete_save(save_id: String) -> bool:
	var save_path = _get_save_path(save_id)
	
	if FileAccess.file_exists(save_path):
		var error = DirAccess.remove_absolute(save_path)
		
		if error == OK:
			if _current_save_id == save_id:
				_current_save_id = ""
			
			save_deleted.emit(save_id)
			return true
	
	return false

# 检查是否有存档
func has_save(save_id: String = "") -> bool:
	if save_id.is_empty():
		# 检查是否有任何存档
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while not file_name.is_empty():
				if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
					return true
				file_name = dir.get_next()
		return false
	else:
		# 检查特定存档
		return FileAccess.file_exists(_get_save_path(save_id))

# 获取当前加载的存档ID
func get_current_save_id() -> String:
	return _current_save_id

# 私有方法
func _get_save_path(save_id: String) -> String:
	return SAVE_DIR + save_id + SAVE_EXTENSION

func _generate_save_id() -> String:
	return "save_" + _get_timestamp()

func _get_timestamp() -> String:
	return str(Time.get_unix_time_from_system())

func _load_entity_states(save_data: SaveData) -> void:
	for entity_data in save_data.entities_state:
		# 尝试通过节点路径找到实体节点
		var node_path := entity_data.node_path
		var entity = get_node_or_null(node_path)
		
		if entity and entity.has_method("load_data"):
			entity.load_data(entity_data)
		else:
			# 记录错误
			CoreSystem.logger.error("无法加载实体状态: " + node_path)
