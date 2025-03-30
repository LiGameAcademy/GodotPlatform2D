extends Node

## 场景路径常量
const MENU_SCENE : String = ResourcePaths.Scenes.MENU
const CHARACTER_SELECT_SCENE : String = ResourcePaths.Scenes.CHARACTER_SELECT
const LEVEL_SELECT_SCENE : String = ResourcePaths.Scenes.LEVEL_SELECT

const SaveManager := preload("res://source/core/save_manager.gd")

## 当前总分数
var score: int = 0:
	set(value):
		if score != value:
			score = value
			GameEvents.UIEvent.push_total_score_changed(score)

# 游戏数据
var current_level := 0
var selected_character_index := 0

var level_manager : LevelManager
var effect_manager : EffectManager
var save_manager : SaveManager

## 角色相关
var characters: Array[PackedScene] = ResourcePaths.Characters.get_all()

func _ready() -> void:
	level_manager = LevelManager.new()
	add_child(level_manager)
	
	effect_manager = EffectManager.new()
	add_child(effect_manager)
	
	save_manager = SaveManager.new()
	add_child(save_manager)

## 游戏启动
func setup() -> void:
	var state_machine : GameFlowStateMachine = GameFlowStateMachine.new()
	CoreSystem.state_machine_manager.register_state_machine("game_flow", state_machine, self, "launch")

## 创建玩家角色
func create_player_character() -> Character:
	var character_scene := ResourcePaths.Characters.get_by_index(selected_character_index)
	if not character_scene:
		push_error("无法加载角色场景")
		return null
		
	var character := character_scene.instantiate() as Character
	if not character:
		push_error("无法实例化角色")
		return null
	
	# 添加玩家控制器
	var player_controller := PlayerController.new()
	player_controller.name = "PlayerController"
	character.add_child(player_controller)
	
	# 添加收集组件
	var collection_component := CollectionComponent.new()
	collection_component.name = "CollectionComponent"
	character.add_child(collection_component)
	
	return character

func create_character_preview(character_scene: PackedScene) -> Character:
	if not character_scene:
		return null
	
	var character: Character = character_scene.instantiate()
	character.is_preview_mode = true
	return character

## 开始新游戏
func start_new_game() -> void:
	# 重置游戏数据
	score = 0
	current_level = 0
	selected_character_index = 0
	
	# 重置关卡管理器数据
	level_manager.reset_game_data()
	
	# 加载第一关
	load_current_level()

## 继续游戏
func continue_game() -> void:
	# 加载存档
	save_manager.load_game()
	
	# 加载当前关卡
	load_current_level()

## 加载当前关卡
func load_current_level() -> void:
	level_manager.load_level(current_level)

## 添加关卡分数到总分
func add_level_score(level_score: int) -> void:
	score += level_score

## 重置分数
func reset_score() -> void:
	score = 0

## 保存游戏
func save_game() -> void:
	save_manager.save_game()

## 删除存档
func delete_save() -> void:
	save_manager.delete_save()

## 返回主菜单
func return_to_menu() -> void:
	# 发送退出游戏事件
	CoreSystem.event_bus.push_event("game_exit_requested")
	# 切换到菜单场景
	show_menu_scene()

## 暂停游戏
func pause_game() -> void:
	get_tree().paused = true

## 恢复游戏
func resume_game() -> void:
	get_tree().paused = false

## 场景切换
func show_menu_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(MENU_SCENE)

func show_character_select_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(CHARACTER_SELECT_SCENE)

func show_level_select_scene() -> void:
	CoreSystem.scene_manager.change_scene_async(LEVEL_SELECT_SCENE)

func get_characters_count() -> int:
	return characters.size()
