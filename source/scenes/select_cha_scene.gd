extends Control

@onready var character_point : Node = %CharacterPoint
var current_character_index := 0
var _character : Character:
	set(value):
		if _character:
			# character_point.remove_child(_character)
			_character.queue_free()
		_character = value
		if _character:
			character_point.add_child(_character)

func _ready() -> void:
	character_point.remove_child(character_point.get_child(0))
	# 初始显示第一个角色
	_update_character_preview()

func _update_character_preview() -> void:
	var character_scene = ResourcePaths.Characters.get_by_index(current_character_index)
	if character_scene:
		var character = GameInstance.create_character_preview(character_scene)
		character.name = "Character"
		_character = character

func _on_btn_next_pressed() -> void:
	var count = GameInstance.get_characters_count()
	if count > 0:
		current_character_index = (current_character_index + 1) % count
		_update_character_preview()

func _on_btn_prev_pressed() -> void:
	var count = GameInstance.get_characters_count()
	if count > 0:
		current_character_index = (current_character_index - 1 + count) % count
		_update_character_preview()

func _on_btn_close_pressed() -> void:
	# CoreSystem.event_bus.push_event(GameEvents.CharacterSelectEvent.CHARACTER_SELECT_CANCELLED)
	GameEvents.CharacterSelectEvent.push_character_select_cancelled()

func _on_btn_enter_game_pressed() -> void:
	var character_scene = ResourcePaths.Characters.get_by_index(current_character_index)
	if character_scene:
		# 创建新的角色实例，而不是使用预览实例
		# CoreSystem.event_bus.push_event(GameEvents.CharacterSelectEvent.CHARACTER_SELECTED, current_character_index)
		GameEvents.CharacterSelectEvent.push_character_selected(current_character_index)
