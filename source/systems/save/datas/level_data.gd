# source/systems/save/level_state_data.gd
extends Resource
class_name LevelData

## 完成状态
@export var completed_levels : Array[bool]
@export var unlocked_levels : Array[bool]
@export var level_index: int = 0
## 关卡得分
@export var level_score: int = 0