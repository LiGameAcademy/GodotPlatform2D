extends Node

## 场景路径常量
const MENU_SCENE : String = ResourcePaths.Scenes.MENU
const CHARACTER_SELECT_SCENE : String = ResourcePaths.Scenes.CHARACTER_SELECT
const LEVEL_SELECT_SCENE : String = ResourcePaths.Scenes.LEVEL_SELECT

## 当前总分数
var score := 0:
	set(value):
		if score != value:
			score = value
			# 发送总分数更新事件
			GameEvents.UIEvent.push_total_score_changed(score)

# 游戏数据
var current_level := 1
var selected_character_index := 0

var level_manager : LevelManager
var effect_manager : EffectManager

## 角色相关
var characters: Array[PackedScene] = ResourcePaths.Characters.get_all()

func _ready() -> void:
	#CoreSystem.event_bus.subscribe(GameEvents.LevelEvent.LEVEL_COMPLETED, _on_level_completed)
	level_manager = LevelManager.new()
	add_child(level_manager)
	
	effect_manager = EffectManager.new()
	add_child(effect_manager)

## 添加关卡分数到总分
func add_level_score(level_score: int) -> void:
	score += level_score

## 重置分数
func reset_score() -> void:
	score = 0

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

func get_characters_count() -> int:
	return characters.size()

#func _on_level_completed(event_data: GameEvents.LevelEvent.LevelCompletedData) -> void:
	#score += event_data.score
