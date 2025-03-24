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
