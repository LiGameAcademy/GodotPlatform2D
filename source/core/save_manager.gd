extends Node

const SAVE_FILE_PATH = "user://save_data.json"

## 保存游戏数据
func save_game() -> void:
	var save_data := {
		"game_instance": _get_game_instance_data(),
		"level_manager": GameInstance.level_manager.save_level_data()
	}
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_error("无法创建存档文件")
		return
		
	var json_string = JSON.stringify(save_data)
	save_file.store_string(json_string)

## 加载游戏数据
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		CoreSystem.logger.info("没有找到存档文件")
		return
		
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		push_error("无法打开存档文件")
		return
		
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
		
	_load_game_instance_data(save_data.get("game_instance", {}))
	if "level_manager" in save_data:
		GameInstance.level_manager.load_level_data(save_data.level_manager)

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
	GameInstance.current_level = data.get("current_level", 1)
	GameInstance.selected_character_index = data.get("selected_character_index", 0)

## 删除存档
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
