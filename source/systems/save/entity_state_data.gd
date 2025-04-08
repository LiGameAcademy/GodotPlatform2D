# source/systems/save/entity_state_data.gd
extends Resource
class_name EntityStateData

@export var entity_type: String = ""
@export var node_path: String = ""
@export var position: Vector2
@export var properties: Dictionary = {}