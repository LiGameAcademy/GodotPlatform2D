# source/systems/save/fruit_state_data.gd
extends EntityStateData
class_name FruitStateData

@export var fruit_type: String = ""
@export var collected: bool = false
@export var respawn_timer: float = 0.0