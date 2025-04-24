extends RefCounted
class_name CollectionData

## 收集的物品数量
var collected_items: int = 0
## 当前连击数
var current_combo: int = 0
## 总分数
var total_score: int = 0
## 连击计时器
var combo_timer: float = 0.0

## 重置数据
func reset() -> void:
	collected_items = 0
	current_combo = 0
	total_score = 0
	combo_timer = 0.0
