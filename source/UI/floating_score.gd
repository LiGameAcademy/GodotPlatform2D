extends Node2D
class_name FloatingScore

## 动画持续时间
@export var animation_duration := 1.0
## 上升距离
@export var rise_height := 10.0
## 初始缩放
@export var initial_scale := Vector2(0.5, 0.5)
## 最大缩放
@export var max_scale := Vector2(1.2, 1.2)
## 最终缩放
@export var final_scale := Vector2(1.0, 1.0)

@onready var label: Label = $Label

var _tween: Tween

func _ready() -> void:
	# 设置初始状态
	scale = initial_scale
	modulate.a = 1.0

## 设置分数并开始动画
func start(score: int, combo: int = 0) -> void:
	# 设置文本
	if combo > 1:
		label.text = "x%d\n%d" % [combo, score]
	else:
		label.text = str(score)
	
	# 创建动画
	_tween = create_tween()
	_tween.set_parallel(true)
	
	# 位置动画
	_tween.tween_property(self, "position:y", 
		position.y - rise_height, animation_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# 缩放动画（先放大后恢复）
	_tween.chain().tween_property(self, "scale",
		max_scale, animation_duration * 0.3
	).set_ease(Tween.EASE_OUT)
	_tween.chain().tween_property(self, "scale",
		final_scale, animation_duration * 0.7
	).set_ease(Tween.EASE_IN)
	
	# 透明度动画
	_tween.tween_property(self, "modulate:a",
		0.0, animation_duration
	).set_ease(Tween.EASE_IN)
	
	# 动画结束后删除节点
	_tween.finished.connect(queue_free)
