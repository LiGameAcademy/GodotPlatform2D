extends Control

@onready var character_point : Node = %CharacterPoint
var current_character_index := 0
var _character : Character:
	set(value):
		if _character:
			character_point.remove_child(_character)
		_character = value
		if _character:
			character_point.add_child(_character)

func _ready() -> void:
	character_point.remove_child(character_point.get_child(0))
	# 初始显示第一个角色
	update_character_preview()

func update_character_preview() -> void:
	var character_scene = GameInstance.get_character(current_character_index)
	if not character_scene:
		return
	# 创建并添加新角色
	_character = GameInstance.create_character_preview(character_scene)

func _on_btn_next_pressed() -> void:
	var count = GameInstance.get_characters_count()
	if count > 0:
		current_character_index = (current_character_index + 1) % count
		update_character_preview()

func _on_btn_prev_pressed() -> void:
	var count = GameInstance.get_characters_count()
	if count > 0:
		current_character_index = (current_character_index - 1 + count) % count
		update_character_preview()

func _on_btn_close_pressed() -> void:
	CoreSystem.event_bus.push_event("character_select_cancelled")

func _on_btn_enter_game_pressed() -> void:
	var character_scene = GameInstance.get_character(current_character_index)
	if character_scene:
		# 创建新的角色实例，而不是使用预览实例
		GameInstance.selected_character = character_scene.instantiate()
		CoreSystem.event_bus.push_event("character_selected")
