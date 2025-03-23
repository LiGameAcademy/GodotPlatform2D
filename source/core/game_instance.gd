extends Node

## 场景路径常量
const MENU_SCENE : String = "res://source/scenes/menu_screen.tscn"
const CHARACTER_SELECT_SCENE : String = "res://source/scenes/select_cha_scene.tscn"
const LEVEL_SELECT_SCENE : String = "res://source/scenes/select_level_scene.tscn"

# 游戏数据
var current_level := 1
var score := 0
var selected_character: Character

var level_manager : LevelManager

## 角色相关
var characters: Array[PackedScene] = [
	preload("res://source/gameplay/character/player_character/mask_dude.tscn"), 
	preload("res://source/gameplay/character/player_character/ninja_frog.tscn"), 
	preload("res://source/gameplay/character/player_character/pink_man.tscn"), 
	preload("res://source/gameplay/character/player_character/virtual_guy.tscn")
]

func _ready() -> void:
	level_manager = LevelManager.new()
	add_child(level_manager)


func create_character_preview(character_scene: PackedScene) -> Character:
	if not character_scene:
		return null
	
	var character: Character = character_scene.instantiate()
	character.is_preview_mode = true
	return character


func get_character(index: int) -> PackedScene:
	if index >= 0 and index < characters.size():
		return characters[index]
	return null


func get_characters_count() -> int:
	return characters.size()


## 游戏启动
func setup() -> void:
	var state_machine : GameFlowStateMachine = GameFlowStateMachine.new()
	CoreSystem.state_machine_manager.register_state_machine("game_flow", state_machine, self, "launch")


func show_menu_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(MENU_SCENE)

func show_character_select_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(CHARACTER_SELECT_SCENE)

func show_level_select_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(LEVEL_SELECT_SCENE)

func load_current_level() -> void:
	level_manager.load_level(current_level)

# 分数管理

func add_score(value: int) -> void:
	score += value

func reset_score() -> void:
	score = 0
