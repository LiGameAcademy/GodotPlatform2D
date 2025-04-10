extends Node

class_name ResourcePaths

# UI Textures
class UITextures:
	const LEVEL_TEXTURES : Array[Texture] = [
		preload("res://assets/textures/ui/texture_icon_01.png"),
		preload("res://assets/textures/ui/texture_icon_02.png"),
		preload("res://assets/textures/ui/texture_icon_03.png"),
		preload("res://assets/textures/ui/texture_icon_04.png"),
		preload("res://assets/textures/ui/texture_icon_05.png"),
		preload("res://assets/textures/ui/texture_icon_06.png"),
		preload("res://assets/textures/ui/texture_icon_49.png"),
		preload("res://assets/textures/ui/texture_icon_50.png")
	]

# Scene Paths
class ScenePaths:
	const LEVELS : Array[String] = [
		"res://source/gameplay/levels/level_01.tscn",
		"res://source/gameplay/levels/level_02.tscn",
		"res://source/gameplay/levels/level_03.tscn",
		"res://source/gameplay/levels/level_04.tscn"
	]
	
	const LEVEL_WIDGET : PackedScene = preload("res://source/ui/widgets/level_widget.tscn")

# Item Textures
class ItemTextures:
	const FRUITS = {
		"apple": preload("res://assets/textures/items/texture_items_fruits_apple.png"),
		"bananas": preload("res://assets/textures/items/texture_items_fruits_bananas.png"),
		"cherries": preload("res://assets/textures/items/texture_items_fruits_cherries.png"),
		"kiwi": preload("res://assets/textures/items/texture_items_fruits_kiwi.png"),
		"melon": preload("res://assets/textures/items/texture_items_fruits_melon.png"),
		"orange": preload("res://assets/textures/items/texture_items_fruits_orange.png"),
		"pineapple": preload("res://assets/textures/items/texture_items_fruits_pineapple.png"),
		"strawberry": preload("res://assets/textures/items/texture_items_fruits_strawberry.png")
	}

static func get_fruit_texture(fruit_name: String) -> Texture:
	return ItemTextures.FRUITS.get(fruit_name, ItemTextures.FRUITS["apple"])

## 资源路径常量
## 场景路径
class Scenes:
	## 菜单场景
	const MENU := "res://source/scenes/menu_screen.tscn"
	## 角色选择场景
	const CHARACTER_SELECT := "res://source/scenes/select_cha_scene.tscn"
	## 关卡选择场景
	const LEVEL_SELECT := "res://source/scenes/select_level_scene.tscn"
	## 主菜单场景
	const MAIN_MENU := "res://source/ui/main_menu.tscn"
	## 游戏场景
	const GAME := "res://source/ui/game.tscn"
	## 角色选择场景
	const CHARACTER_SELECT_UI := "res://source/ui/character_select.tscn"
	## 关卡选择场景
	const LEVEL_SELECT_UI := "res://source/ui/level_select.tscn"
	## 分数漂字场景
	const FLOATING_SCORE := "res://source/ui/floating_score.tscn"

## UI路径
class UI:
	## 设置弹窗
	const SETTINGS_DIALOG := "res://source/ui/settings/settings_dialog.tscn"
	## 输入映射项
	const INPUT_MAPPING_ITEM := "res://source/ui/settings/input_mapping_item.tscn"
	## 音量滑块项
	const VOLUME_SLIDER_ITEM := "res://source/ui/settings/volume_slider_item.tscn"
	## 图形选项项
	const GRAPHICS_OPTION_ITEM := "res://source/ui/settings/graphics_option_item.tscn"
	## 语言选项预制场景
	const LANGUAGE_OPTION := "res://source/ui/settings/language_option.tscn"

## UI效果路径
class Effects:
	## 分数漂字效果
	const FLOATING_SCORE := "res://source/ui/floating_score.tscn"

## 角色路径
class Characters:
	## 面具小子
	const MASK_DUDE := "res://source/gameplay/character/player_character/mask_dude.tscn"
	## 忍者蛙
	const NINJA_FROG := "res://source/gameplay/character/player_character/ninja_frog.tscn"
	## 粉红人
	const PINK_MAN := "res://source/gameplay/character/player_character/pink_man.tscn"
	## 虚拟人
	const VIRTUAL_GUY := "res://source/gameplay/character/player_character/virtual_guy.tscn"

	## 获取所有角色场景
	static func get_all() -> Array[PackedScene]:
		return [
			preload(MASK_DUDE),
			preload(NINJA_FROG),
			preload(PINK_MAN),
			preload(VIRTUAL_GUY)
		]
		
	## 根据索引获取角色场景
	## [param index] 角色索引
	## [returns] 角色场景，如果索引无效则返回null
	static func get_by_index(index: int) -> PackedScene:
		var scenes = get_all()
		if index >= 0 and index < scenes.size():
			return scenes[index]
		return null

class Audios:

	const LEVEL_BGM := "res://assets/audios/level_bgm.wav"
	const MENU_BGM := "res://assets/audios/menu_bgm.wav"