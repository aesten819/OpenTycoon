extends Node2D
class_name Building

# Building.gd
# Represents a static object on the grid (Gate, Shop, Decoration)

@export var texture: Texture2D
@export var offset_y: float = 0.0

@onready var sprite = $Sprite2D

func _ready():
	if texture:
		sprite.texture = texture
		# Center bottom of sprite at (0,0) usually
		sprite.offset.y = -sprite.texture.get_height() / 2.0 + offset_y
		# But with 3D depth, we usually want bottom center anchored.
		# Adjust as needed.
		sprite.position.y = 8 # Slight offset for grid alignment if needed.

func set_highlight(active: bool):
	if active:
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color.WHITE
