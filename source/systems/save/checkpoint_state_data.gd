# source/systems/save/checkpoint_state_data.gd
extends EntityStateData
class_name CheckpointStateData

@export var activated: bool = false
@export var checkpoint_id: String = ""