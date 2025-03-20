@tool
extends BaseTransition
class_name LevelTransition

const DIAMOND_BASED_SCREEN_TRANSITION = preload("res://assets/shader/diamond_based_screen_transition.gdshader")

var color_rect : ColorRect

func init(transition_rect: ColorRect = null) -> void:
	if color_rect and color_rect.is_inside_tree():
		color_rect.queue_free()
		
	super(transition_rect)
	color_rect = ColorRect.new()
	color_rect.material = ShaderMaterial.new()
	color_rect.material.shader = DIAMOND_BASED_SCREEN_TRANSITION
	color_rect.size = Vector2(1920, 1080)  # 设置一个足够大的尺寸
	color_rect.position = Vector2(-960, -540)  # 居中显示
	if transition_rect:
		transition_rect.add_child(color_rect)
		# 设置材质初始值
		color_rect.material.set_shader_parameter("progress", 0.0)

func _do_start(duration: float) -> void:
	if not _transition_rect:
		return
	var tween := _transition_rect.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 1, duration).from(0)
	await tween.finished

func _do_end(duration: float) -> void:
	if not _transition_rect:
		return
	color_rect.color = Color.BLACK
	var tween := _transition_rect.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 0, duration).from(1)
	await tween.finished

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if color_rect and color_rect.is_inside_tree():
			color_rect.queue_free()
