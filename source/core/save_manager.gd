extends Node

const SAVE_FILE_PATH = "user://save_data.json"

## 保存游戏数据
func save_game() -> void:
	# 获取需要保存的数据
	var save_data := {
		"game_instance": _get_game_instance_data(),
		"level_manager": GameInstance.level_manager.save_level_data()
	}
	
	# 尝试打开存档文件
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_error("无法创建存档文件")
		return
	
	# 将数据转换为格式化的JSON字符串
	var json_string = JSON.stringify(save_data, "\t")
	save_file.store_string(json_string)
	CoreSystem.logger.info("游戏已保存")

## 加载游戏数据
func load_game() -> void:
	# 检查存档文件是否存在
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		CoreSystem.logger.info("没有找到存档文件")
		return
	
	# 尝试打开存档文件
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		push_error("无法打开存档文件")
		return
	
	# 读取并解析JSON数据
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("解析存档文件失败")
		return
	
	var save_data = json.data
	if not save_data is Dictionary:
		push_error("存档数据格式错误")
		return
	
	# 加载游戏实例数据
	_load_game_instance_data(save_data.get("game_instance", {}))
	
	# 加载关卡管理器数据
	if "level_manager" in save_data:
		GameInstance.level_manager.load_level_data(save_data.level_manager)
	
	CoreSystem.logger.info("游戏已加载")

## 获取游戏实例数据
func _get_game_instance_data() -> Dictionary:
	return {
		"score": GameInstance.score,
		"current_level": GameInstance.current_level,
		"selected_character_index": GameInstance.selected_character_index
	}

## 加载游戏实例数据
func _load_game_instance_data(data: Dictionary) -> void:
	GameInstance.score = data.get("score", 0)
	GameInstance.current_level = data.get("current_level", 0)
	GameInstance.selected_character_index = data.get("selected_character_index", 0)

## 删除存档
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var error = DirAccess.remove_absolute(SAVE_FILE_PATH)
		if error == OK:
			CoreSystem.logger.info("存档已删除")
		else:
			push_error("删除存档失败")

## 检查是否有存档
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)
