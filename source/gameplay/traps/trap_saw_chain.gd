@tool
extends Path2D

@export var sprite : Texture
@export var show_chain : bool = true
@export var chain_width : float = 10.0

func _ready() -> void:
	if not show_chain : return
	var points = curve.get_baked_length() / chain_width
	for point in points:
		var sample_baked = curve.sample_baked(point * chain_width)
		var chain = Sprite2D.new()
		chain.texture = sprite
		add_child(chain)
		chain.position = sample_baked
		
