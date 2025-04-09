# source/systems/save/checkpoint_state_data.gd
extends EntityData
class_name CheckpointData

@export var activated: bool = false
@export var checkpoint_id: String = ""