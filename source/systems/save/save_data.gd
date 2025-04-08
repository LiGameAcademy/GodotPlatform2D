extends Resource
class_name SaveData

# 存档元数据
@export var save_id : StringName = &""
@export var timestamp : int = 0
@export var save_date : String = ""
@export var game_version : String = ""
@export var playtime : float = 0.0
@export var screenshot : Image

# @export var level_index : int = 0
# @export var total_score : int = 0

# 游戏数据
@export var game_state : GameStateData
@export var level_state: LevelStateData
@export var entities_state : Array[EntityStateData]
