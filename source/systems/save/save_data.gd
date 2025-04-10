extends Resource
class_name SaveData

# 存档元数据
@export var save_id : StringName = &""
@export var timestamp : int = 0
@export var save_date : String = ""
@export var game_version : String = ""
@export var playtime : float = 0.0

# 游戏数据
@export var game_state : GameData
@export var level_state: LevelData
@export var entities_state : Array[EntityData]

func _init(
		p_save_id: StringName = "",
		p_timestamp: int = 0,
		p_save_date: String = "",
		p_game_version: String = "",
		p_playtime: float = 0.0,
		p_game_state: GameData = null,
		p_level_state: LevelData = null,
		p_entities_state: Array[EntityData] = []
		) -> void:
	save_id = p_save_id
	timestamp = p_timestamp
	save_date = p_save_date
	game_version = p_game_version
	playtime = p_playtime
	
	game_state = p_game_state
	level_state = p_level_state
	entities_state = p_entities_state
	
