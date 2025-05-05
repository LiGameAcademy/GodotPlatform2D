@tool
extends BaseTransition
class_name LevelTransition

const DIAMOND_BASED_SCREEN_TRANSITION = preload("res://assets/shader/diamond_based_screen_transition.gdshader")

func init(transition_rect: ColorRect) -> void:
	super(transition_rect)
	
	# 设置转场矩形的属性
	_transition_rect.material = ShaderMaterial.new()
	_transition_rect.material.shader = DIAMOND_BASED_SCREEN_TRANSITION
	_transition_rect.material.set_shader_parameter("progress", 0.0)
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 忽略鼠标输入

func _do_start(duration: float) -> void:
	if not _transition_rect or not _transition_rect.material:
		return
	_transition_rect.color = Color.BLACK
	var tween := _transition_rect.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_transition_rect.material, "shader_parameter/progress", 1, duration).from(0)
	await tween.finished

func _do_end(duration: float) -> void:
	if not _transition_rect or not _transition_rect.material:
		return
	var tween := _transition_rect.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_transition_rect.material, "shader_parameter/progress", 0, duration).from(1)
	await tween.finished
