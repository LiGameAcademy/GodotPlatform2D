# source/systems/save/level_state_data.gd
extends Resource
class_name LevelStateData

## 关卡数据
@export var level_index: int = 0
## 关卡得分
@export var level_score: int = 0
## 是否完成
@export var completed: bool = false
## 收集的果实
@export var fruits_collected: Array[String] = []
## 激活的检查点
@export var checkpoints_activated: Array[String] = []