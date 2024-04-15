@tool
extends MarginContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

@export var level_scene : PackedScene = null
@export var level_icon : Texture = null

signal pressed

func _ready() -> void:
	texture_rect.texture = level_icon
	$SubViewportContainer/SubViewport.remove_child($SubViewportContainer/SubViewport.get_child(0))
	$SubViewportContainer/SubViewport.add_child(level_scene.instantiate())

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print(self, "pressed")
			pressed.emit()
