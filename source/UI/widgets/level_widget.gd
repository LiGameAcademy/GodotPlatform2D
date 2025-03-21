@tool
extends MarginContainer
class_name LevelWidget

const level_count_texture : Array[Texture] = [
	preload("res://assets/textures/texture_icon_01.png"), 
	preload("res://assets/textures/texture_icon_02.png"), 
	preload("res://assets/textures/texture_icon_03.png"), 
	preload("res://assets/textures/texture_icon_04.png"), 
	preload("res://assets/textures/texture_icon_05.png"), 
	preload("res://assets/textures/texture_icon_06.png"), 
	preload("res://assets/textures/texture_icon_49.png"), 
	preload("res://assets/textures/texture_icon_50.png")]

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var label_status: Label = %LabelStatus
@onready var sub_viewport: SubViewport = %SubViewport

signal level_clicked

var level_index: int = 0
var is_unlocked: bool = false:
	set(value):
		is_unlocked = value
		if not is_unlocked:
			label_status.text = "未解锁"

var is_completed: bool = false:
	set(value):
		is_completed = value
		if is_completed:
			label_status.text = "已完成"

func _ready() -> void:
	if not Engine.is_editor_hint():
		label_status.text = ""
		sub_viewport.remove_child(sub_viewport.get_child(0))

func set_level_info(p_level_index: int, unlocked: bool = false, completed: bool = false) -> void:
	level_index = p_level_index
	is_unlocked = unlocked
	is_completed = completed
	# 根据状态设置外观
	modulate = Color.WHITE if unlocked else Color(0.5, 0.5, 0.5, 1.0)
	var level_preview := GameInstance.level_manager.create_level_preview(level_index)
	sub_viewport.add_child(level_preview)
	texture_rect.texture = level_count_texture[level_index]

func _on_gui_input(event: InputEvent) -> void:
	if not is_unlocked:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		level_clicked.emit()
