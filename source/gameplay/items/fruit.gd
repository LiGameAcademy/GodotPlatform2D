extends Node2D
class_name Fruit

# 水果类型和对应的纹理
const FRUIT_TYPES = ResourcePaths.ItemTextures.FRUITS

# 水果参数
@export_group("Fruit")
@export var fruit_type: String = ""  # 水果类型，空字符串表示随机
@export var score_multiplier = 1.0   # 分数倍率

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_collected: Sprite2D = $sprite_collected

# 当前水果类型
var _current_type: String = ""
var _collected = false

signal collected(fruit: Fruit)


func _ready() -> void:
	# 设置水果类型和纹理
	if fruit_type.is_empty():
		_current_type = FRUIT_TYPES.keys().pick_random()
		sprite_2d.texture = FRUIT_TYPES[_current_type]
	else:
		_current_type = fruit_type
		sprite_2d.texture = FRUIT_TYPES[fruit_type]
	
	# 播放空闲动画
	animation_player.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if not body is Character or _collected:
		return
		
	_collected = true
	
	# 发送收集事件
	GameEvents.CollectionEvent.push_fruit_collected(body, self, _current_type, global_position)
	
	# 播放收集动画
	_play_collect_animation()
	collected.emit(self)


func _play_collect_animation() -> void:
	animation_player.play("collected")
	await animation_player.animation_finished
	queue_free()


## 保存水果状态
func save_state() -> Dictionary:
	return {
		"type": _current_type,
		"collected": _collected,
		"position": {"x": position.x, "y": position.y}
	}


## 加载水果状态
func load_state(state: Dictionary) -> void:
	if "type" in state:
		_current_type = state.type
		sprite_2d.texture = FRUIT_TYPES[_current_type]
	
	if "collected" in state and state.collected:
		_collected = true
		# 如果已收集，则直接显示收集后的状态
		sprite_2d.hide()
		sprite_collected.show()
		
	if "position" in state:
		position = Vector2(state.position.x, state.position.y)


## 获取水果数据
func get_fruit_data() -> Dictionary:
	return {
		"type": _current_type,
		"score_multiplier": score_multiplier,
		"collected": _collected
	}


## 获取当前水果类型
func get_type() -> String:
	return _current_type


## 是否已被收集
func is_collected() -> bool:
	return _collected
