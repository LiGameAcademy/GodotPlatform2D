extends CoreSystem.GameStateData.NodeData
class_name GameData

@export var score: int = 0
@export var current_level: int = 0
@export var selected_character_index: int = 0

func _init(p_score: int = 0, p_current_level: int = 0, p_selected_character_index: int = 0) -> void:
	score = p_score
	current_level = p_current_level
	selected_character_index = p_selected_character_index
