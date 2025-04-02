extends Node

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".json"

signal save_loaded(save_index: int)
signal save_created(save_index: int)

# 初始化
func _ready():
    # 确保存档目录存在
    if not DirAccess.dir_exists_absolute(SAVE_DIR):
        DirAccess.make_dir_absolute(SAVE_DIR)

# 获取存档文件路径
func _get_save_path(save_index: int) -> String:
    return SAVE_DIR + "save_" + str(save_index) + SAVE_EXTENSION

# 保存游戏数据
func save_game(save_index: int, save_name: String = "") -> void:
    # 获取需要保存的数据
    var save_data := {
        "meta": {
            "save_name": save_name if save_name else "存档 " + str(save_index),
            "save_date": Time.get_datetime_string_from_system(),
            "game_version": ProjectSettings.get_setting("application/config/version", "1.0.0")
        },
        "game_instance": _get_game_instance_data(),
        "character": _get_character_data(),
        "level": _get_level_data()
    }
    
    # 保存到文件
    var save_path = _get_save_path(save_index)
    var save_file = FileAccess.open(save_path, FileAccess.WRITE)
    if save_file == null:
        push_error("无法创建存档文件: " + save_path)
        return
    
    var json_string = JSON.stringify(save_data, "\t")
    save_file.store_string(json_string)
    CoreSystem.logger.info("游戏已保存到: " + save_path)
    
    emit_signal("save_created", save_index)

# 加载游戏数据
func load_game(save_index: int) -> bool:
    var save_path = _get_save_path(save_index)
    
    # 检查存档文件是否存在
    if not FileAccess.file_exists(save_path):
        CoreSystem.logger.info("没有找到存档文件: " + save_path)
        return false
    
    # 读取文件
    var save_file = FileAccess.open(save_path, FileAccess.READ)
    if save_file == null:
        push_error("无法打开存档文件: " + save_path)
        return false
    
    # 解析JSON
    var json_string = save_file.get_as_text()
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        push_error("解析存档文件失败: " + save_path)
        return false
    
    var save_data = json.data
    if not save_data is Dictionary:
        push_error("存档数据格式错误")
        return false
    
    # 加载数据
    _load_game_instance_data(save_data.get("game_instance", {}))
    _load_character_data(save_data.get("character", {}))
    _load_level_data(save_data.get("level", {}))
    
    CoreSystem.logger.info("游戏已加载: " + save_path)
    emit_signal("save_loaded", save_index)
    return true

# 获取存档列表
func get_save_list() -> Array:
    var saves = []
    var dir = DirAccess.open(SAVE_DIR)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
                var save_index = file_name.replace("save_", "").replace(SAVE_EXTENSION, "")
                if save_index.is_valid_int():
                    var save_path = SAVE_DIR + file_name
                    var save_info = _get_save_info(save_path)
                    if save_info:
                        saves.append(save_info)
            
            file_name = dir.get_next()
    
    # 按照日期排序，最新的排在前面
    saves.sort_custom(func(a, b): return a.save_date > b.save_date)
    
    return saves

# 获取存档信息
func _get_save_info(save_path: String) -> Dictionary:
    var save_file = FileAccess.open(save_path, FileAccess.READ)
    if save_file == null:
        return {}
    
    var json_string = save_file.get_as_text()
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        return {}
    
    var save_data = json.data
    if not save_data is Dictionary or not "meta" in save_data:
        return {}
    
    # 提取索引 - 修复正则匹配方式
    var file_name = save_path.get_file()
    var save_index_str = file_name.replace("save_", "").replace(SAVE_EXTENSION, "")
    var index = int(save_index_str) if save_index_str.is_valid_int() else -1
    
    return {
        "index": index,
        "name": save_data.meta.get("save_name", "未命名存档"),
        "save_date": save_data.meta.get("save_date", ""),
        "level": save_data.game_instance.get("current_level", 0),
        "score": save_data.game_instance.get("score", 0)
    }

# 删除存档
func delete_save(save_index: int) -> bool:
    var save_path = _get_save_path(save_index)
    if FileAccess.file_exists(save_path):
        var error = DirAccess.remove_absolute(save_path)
        if error == OK:
            CoreSystem.logger.info("存档已删除: " + save_path)
            return true
        else:
            push_error("删除存档失败: " + save_path)
    return false

# 检查存档是否存在
func has_save(save_index: int) -> bool:
    return FileAccess.file_exists(_get_save_path(save_index))

# 获取空存档槽
func get_empty_save_slot() -> int:
    var index = 1
    while has_save(index):
        index += 1
    return index

# 以下是数据获取和加载方法
func _get_game_instance_data() -> Dictionary:
    return {
        "score": GameInstance.score,
        "current_level": GameInstance.current_level,
        "selected_character_index": GameInstance.selected_character_index
    }

func _load_game_instance_data(data: Dictionary) -> void:
    GameInstance.score = data.get("score", 0)
    GameInstance.current_level = data.get("current_level", 0)
    GameInstance.selected_character_index = data.get("selected_character_index", 0)

func _get_character_data() -> Dictionary:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return {}
    
    return {
        "position": {"x": player.global_position.x, "y": player.global_position.y},
        "velocity": {"x": player.velocity.x, "y": player.velocity.y},
        # 可以添加更多角色属性
    }

func _load_character_data(data: Dictionary) -> void:
    # 这些数据将在角色加载时应用
    GameInstance.cached_character_data = data

func _get_level_data() -> Dictionary:
    var level = get_tree().current_scene
    if not level or not level.has_method("save_level_data"):
        return {}
    
    return level.save_level_data()

func _load_level_data(data: Dictionary) -> void:
    # 这些数据将在关卡加载时应用
    GameInstance.cached_level_data = data
