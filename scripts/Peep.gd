extends Node2D
class_name Peep

# Peep.gd
# Controls the guest ai, movement, and visual animation

var map_manager # Reference to MapManager
var current_path: Array[Vector2i] = []
var current_target: Vector2
var speed: float = 32.0 # Pixels per second
var is_moving: bool = false
@onready var sprite = $Sprite2D

enum State {
	IDLE,
	WALKING,
	DOING_ACTIVITY
}
var state: State = State.IDLE

func _ready():
	# Setup AnimatedSprite
	if sprite.sprite_frames.has_animation("walk"):
		sprite.play("walk")
	
	# Setup Shader Material for Random Shirt Color
	var mat = ShaderMaterial.new()
	mat.shader = load("res://assets/peep/peep_shader.gdshader")
	
	# Random Color (Pastel/Bright colors)
	var random_col = Color.from_hsv(randf(), 0.7, 0.9)
	mat.set_shader_parameter("shirt_color", random_col)
	mat.set_shader_parameter("mask_color", Color(1, 0, 0)) # Red
	
	sprite.material = mat
	
	# Start moving after a short delay
	await get_tree().create_timer(0.5).timeout
	_request_new_path()

func _process(delta):
	match state:
		State.IDLE:
			# Just wait a bit then move
			if randf() < 0.02: # 2% chance per frame to start moving if idle
				_request_new_path()
				
		State.WALKING:
			_follow_path(delta)
			_animate_walk(delta)

func _animate_walk(_delta):
	if is_moving:
		if not sprite.is_playing():
			sprite.play("walk")
			
		# Flip H based on direction
		# velocity is not stored, but we can infer from current_target - position
		var dir = (current_target - position).x
		if dir < -0.1:
			sprite.flip_h = true
		elif dir > 0.1:
			sprite.flip_h = false
	else:
		if sprite.is_playing():
			sprite.stop()
			sprite.frame = 0

func _follow_path(delta):
	if current_path.is_empty():
		state = State.IDLE
		is_moving = false
		return
		
	is_moving = true
	
	# Get target world position
	if current_path.size() > 0:
		var target_grid = current_path[0]
		if map_manager and map_manager.terrain_layer:
			current_target = map_manager.terrain_layer.map_to_local(target_grid)
		else:
			return
	
	var dist = position.distance_to(current_target)
	if dist < 2.0:
		current_path.pop_front()
		if current_path.is_empty():
			state = State.IDLE
			is_moving = false
	else:
		var direction = (current_target - position).normalized()
		position += direction * speed * delta

func _request_new_path():
	if not map_manager: 
		# Attempt to find map manager if lost
		map_manager = get_tree().get_first_node_in_group("MapManager")
		if not map_manager: return
	
	var random_tile = map_manager.get_random_road_tile()
	if random_tile == Vector2i(-1, -1):
		return # No roads
		
	var my_grid_pos = map_manager.terrain_layer.local_to_map(position)
	
	# Request Path
	var new_path = map_manager.get_peep_path(my_grid_pos, random_tile)
	if not new_path.is_empty():
		current_path = new_path
		state = State.WALKING
	else:
		# Maybe already there or no path
		state = State.IDLE
