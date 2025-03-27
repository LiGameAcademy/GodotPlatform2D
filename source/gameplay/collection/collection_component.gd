extends Node
class_name CollectionComponent

## 基础得分
@export var base_score := 100
## 最大连击数
@export var max_combo := 5
## 连击时间窗口（秒）
@export var combo_time_window := 2.0
## 连击加成系数（每次连击增加的分数百分比）
@export_range(0.0, 1.0) var combo_bonus_factor := 0.5

## 收集数据
var collection_data := CollectionData.create()

## 订阅事件
func _ready() -> void:
	CoreSystem.event_bus.subscribe(GameEvents.CollectionEvent.FRUIT_COLLECTED, _on_fruit_collected)

func _process(delta: float) -> void:
	_update_combo_timer(delta)

## 更新连击计时器
func _update_combo_timer(delta: float) -> void:
	if collection_data.current_combo > 0:
		collection_data.combo_timer -= delta
		if collection_data.combo_timer <= 0:
			GameEvents.CollectionEvent.push_combo_ended(collection_data.current_combo)
			collection_data.current_combo = 0

## 获取收集数据
func get_collection_data() -> Dictionary:
	return collection_data.to_dictionary()

## 处理水果收集事件
func _on_fruit_collected(event_data) -> void:
	# 检查是否是当前角色收集的
	if event_data.collector != get_parent():
		return
		
	collection_data.collected_items += 1
	
	# 更新连击
	collection_data.current_combo = min(collection_data.current_combo + 1, max_combo)
	collection_data.combo_timer = combo_time_window
	
	# 计算分数
	var combo_multiplier = 1.0 + (collection_data.current_combo - 1) * combo_bonus_factor
	var score = roundi(base_score * combo_multiplier)
	collection_data.total_score += score
	
	# 发送分数改变事件
	GameEvents.CollectionEvent.push_score_changed(
	 	score,
	 	collection_data.current_combo,
	 	event_data.position
	 )
 
