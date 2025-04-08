# source/systems/save/save_system.gd
extends Node
class_name SaveSystem

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
func create_save(save_id: String = "", screenshot: Image = null) -> String:
    var actual_id = save_id
    if actual_id.is_empty():
        actual_id = _generate_save_id()
    
    # 创建存档数据资源
    var save_data = SaveData.new()
    save_data.save_id = actual_id
    save_data.timestamp = Time.get_unix_time_from_system()
    save_data.save_date = Time.get_datetime_string_from_system()
    save_data.game_version = ProjectSettings.get_setting("application/config/version", "1.0.0")
    # save_data.level_index = GameInstance.current_level
    # save_data.total_score = GameInstance.score
    save_data.playtime = GameStats.get_total_playtime() if "GameStats" in get_parent() else 0.0
    
    if screenshot:
        # 调整截图大小以节省空间
        var small_screenshot = screenshot.duplicate()
        small_screenshot.resize(160, 90, Image.INTERPOLATE_BILINEAR)
        save_data.screenshot = small_screenshot
    
    # 收集游戏状态
    save_data.game_state = _collect_game_state()
    
    # 收集关卡状态
    save_data.level_state = _collect_level_state()
    
    # 收集实体状态
    save_data.entities_state = _collect_entities_state()
    
    # 保存数据到文件
    var save_path = _get_save_path(actual_id)
    var error = ResourceSaver.save(save_data, save_path)
    
    if error == OK:
        _current_save_id = actual_id
        save_created.emit(actual_id, _create_metadata_dict(save_data))
    else:
        push_error("保存游戏失败: " + str(error))
    
    return actual_id

# 加载存档
func load_save(save_id: String) -> bool:
    var save_path = _get_save_path(save_id)
    
    if not FileAccess.file_exists(save_path):
        push_error("存档文件不存在: " + save_path)
        return false
    
    var save_data = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
    if not save_data is SaveData:
        push_error("无效的存档数据")
        return false
    
    # 加载游戏状态
    _apply_game_state(save_data.game_state)
    
    # 加载关卡状态
    _apply_level_state(save_data.level_state)
    
    # 加载实体状态
    # 注意：实体状态通常在关卡加载后应用
    
    _current_save_id = save_id
    save_loaded.emit(save_id, _create_metadata_dict(save_data))
    return true

# 创建自动存档
func create_auto_save(screenshot: Image = null) -> String:
    var auto_save_id = AUTO_SAVE_PREFIX + _get_timestamp()
    var save_id = create_save(auto_save_id, screenshot)
    
    # 清理旧的自动存档
    _clean_old_auto_saves()
    
    auto_save_created.emit(save_id)
    return save_id

# 创建快速存档
func create_quick_save(screenshot: Image = null) -> String:
    var quick_save_id = QUICK_SAVE_PREFIX + _get_timestamp()
    return create_save(quick_save_id, screenshot)

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
                        "metadata": _create_metadata_dict(save_data)
                    })
            
            file_name = dir.get_next()
    
    # 按时间戳排序，最新的在前面
    saves.sort_custom(func(a, b): return a.metadata.timestamp > b.metadata.timestamp)
    
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

func _create_metadata_dict(save_data: SaveData) -> Dictionary:
    return {
        "id": save_data.save_id,
        "timestamp": save_data.timestamp,
        "save_date": save_data.save_date,
        "game_version": save_data.game_version,
        "level_index": save_data.level_index,
        "total_score": save_data.total_score,
        "playtime": save_data.playtime,
        "screenshot": save_data.screenshot
    }

# 收集游戏状态
func _collect_game_state() -> Dictionary:
    # 获取GameInstance的状态
    return {
        "score": GameInstance.score,
        "current_level": GameInstance.current_level,
        "selected_character_index": GameInstance.selected_character_index
    }

# 应用游戏状态
func _apply_game_state(game_state: Dictionary) -> void:
    GameInstance.score = game_state.get("score", 0)
    GameInstance.current_level = game_state.get("current_level", 0)
    GameInstance.selected_character_index = game_state.get("selected_character_index", 0)

# 收集关卡状态
func _collect_level_state() -> Dictionary:
    # 获取当前关卡的状态
    if GameInstance.level_manager and is_instance_valid(GameInstance.level_manager):
        return GameInstance.level_manager.save_level_data()
    return {}

# 应用关卡状态
func _apply_level_state(level_state: Dictionary) -> void:
    if GameInstance.level_manager and is_instance_valid(GameInstance.level_manager):
        GameInstance.level_manager.load_level_data(level_state)

# 收集所有标记为"saveable"的实体状态
func _collect_entities_state() -> Dictionary:
    var entities_state = {}
    var saveables = get_tree().get_nodes_in_group("saveable")
    
    for node in saveables:
        if node.has_method("save"):
            var node_path = str(node.get_path())
            entities_state[node_path] = node.save()
    
    return entities_state

# 应用实体状态
func _apply_entities_state(entities_state: Dictionary) -> void:
    # 注意：这通常应该在关卡加载后调用
    # 因为节点路径可能会改变
    
    # 遍历所有可保存的节点
    var saveables = get_tree().get_nodes_in_group("saveable")
    
    for node in saveables:
        var node_path = str(node.get_path())
        if node_path in entities_state and node.has_method("load"):
            node.load(entities_state[node_path])

# 清理旧的自动存档
func _clean_old_auto_saves() -> void:
    var auto_saves = []
    var saves = get_save_list()
    
    # 筛选出自动存档
    for save in saves:
        if save.id.begins_with(AUTO_SAVE_PREFIX):
            auto_saves.append(save)
    
    # 如果自动存档数量超过限制，删除最旧的
    if auto_saves.size() > MAX_AUTO_SAVES:
        # 已经按时间戳排序，最旧的在最后
        for i in range(MAX_AUTO_SAVES, auto_saves.size()):
            delete_save(auto_saves[i].id)