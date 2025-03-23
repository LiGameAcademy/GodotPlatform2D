extends Node2D
class_name Fruit

# 水果类型和对应的纹理
const FRUIT_TYPES = {
	"apple": preload("res://assets/textures/items/texture_items_fruits_apple.png"),
	"bananas": preload("res://assets/textures/items/texture_items_fruits_bananas.png"),
	"cherries": preload("res://assets/textures/items/texture_items_fruits_cherries.png"),
	"kiwi": preload("res://assets/textures/items/texture_items_fruits_kiwi.png"),
	"melon": preload("res://assets/textures/items/texture_items_fruits_melon.png"),
	"orange": preload("res://assets/textures/items/texture_items_fruits_orange.png"),
	"pineapple": preload("res://assets/textures/items/texture_items_fruits_pineapple.png"),
	"strawberry": preload("res://assets/textures/items/texture_items_fruits_strawberry.png")
}

# 水果参数
@export_group("Fruit")
@export var fruit_type: String = ""  # 水果类型，空字符串表示随机
@export var score_multiplier = 1.0   # 分数倍率
@export var collection_effect = true  # 是否显示收集特效

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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _collected or not body is Character:
		return
	
	_collected = true
	
	# 播放收集动画
	if collection_effect:
		animation_player.play("collected")
		await animation_player.animation_finished
	
	# 通知角色和其他监听者
	if body and is_instance_valid(body):
		body.collect_item(_current_type)
		collected.emit(self)
	
	# 移除水果
	queue_free()


## 获取水果数据
func get_fruit_data() -> Dictionary:
	return {
		"type": _current_type,
		"score_multiplier": score_multiplier,
		"collected": _collected
	}
