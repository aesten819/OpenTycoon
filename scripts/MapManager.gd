extends Node
class_name MapManager

# MapManager.gd
# Handles the logical park data and updates the visual TileMapLayer

@export var terrain_layer: TileMapLayer
@export var map_size: Vector2i = Vector2i(32, 32)
@export var road_source_id: int = 1
@export var road_atlas_coord: Vector2i = Vector2i(0, 0)
@export var hud: CanvasLayer 

# Tile Constants
const SOURCE_ID = 0
const TILE_GRASS = Vector2i(0, 0)
const TILE_ROAD = Vector2i(1, 0) 

# Core Systems
var astar: AStarGrid2D
var building_container: Node2D
var cursor_sprite: Sprite2D
var spawn_timer: Timer

# Scenes
var gate_scene: PackedScene
var peep_scene: PackedScene

# Game State
enum GameMode {
	VIEW = 0,
	BUILD_ROAD = 1,
	DEMOLISH = 2,
	BUILD_GATE = 3
}
var current_mode: int = GameMode.VIEW
var gate_positions: Array[Vector2i] = []

func _ready():
	add_to_group("MapManager")
	
	if terrain_layer:
		generate_flat_terrain()
		_setup_cursor()
		_setup_building_container()
		_setup_astar()
	else:
		push_error("MapManager: Terrain Layer is not assigned!")
	
	gate_scene = load("res://scenes/Gate.tscn")
	peep_scene = load("res://scenes/Peep.tscn")
	
	_setup_spawn_timer()
	
	if hud:
		if hud.has_signal("mode_requested"):
			hud.mode_requested.connect(_set_mode)

func _setup_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 3.0
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout():
	for gate_pos in gate_positions:
		spawn_peep(gate_pos)

func spawn_peep(start_pos: Vector2i):
	if not peep_scene: return
	
	var peep = peep_scene.instantiate()
	peep.position = terrain_layer.map_to_local(start_pos)
	
	building_container.add_child(peep)
	peep.map_manager = self
	print("Spawned Peep at ", start_pos)

func _setup_astar():
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, map_size.x, map_size.y)
	astar.cell_size = Vector2(64, 32)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	astar.fill_solid_region(astar.region, true)

func set_tile_walkable(grid_pos: Vector2i, walkable: bool):
	if astar:
		astar.set_point_solid(grid_pos, not walkable)

func get_peep_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if astar:
		return astar.get_id_path(from, to)
	return []

func get_random_road_tile() -> Vector2i:
	if not terrain_layer: return Vector2i(-1, -1)
	var roads = terrain_layer.get_used_cells_by_id(road_source_id, road_atlas_coord)
	if roads.is_empty():
		return Vector2i(-1, -1)
	return roads.pick_random()

func _process(_delta):
	if not terrain_layer or not cursor_sprite:
		return
		
	var mous_pos = terrain_layer.get_global_mouse_position()
	var grid_pos = terrain_layer.local_to_map(mous_pos)
	
	if current_mode == GameMode.VIEW:
		cursor_sprite.visible = false
	else:
		cursor_sprite.visible = true
		cursor_sprite.position = terrain_layer.map_to_local(grid_pos)
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not Input.is_action_pressed("ui_right"):
				_handle_click(grid_pos)

func _handle_click(grid_pos: Vector2i):
	if grid_pos.x < 0 or grid_pos.x >= map_size.x or grid_pos.y < 0 or grid_pos.y >= map_size.y:
		return

	match current_mode:
		GameMode.BUILD_ROAD:
			terrain_layer.set_cell(grid_pos, road_source_id, road_atlas_coord)
			set_tile_walkable(grid_pos, true)
		GameMode.DEMOLISH:
			var current_source = terrain_layer.get_cell_source_id(grid_pos)
			if current_source == road_source_id:
				terrain_layer.set_cell(grid_pos, SOURCE_ID, TILE_GRASS)
				set_tile_walkable(grid_pos, false)
		GameMode.BUILD_GATE:
			place_gate(grid_pos)

func place_gate(grid_pos: Vector2i):
	if has_node("Buildings") and building_container.get_child_count() > 0:
		for child in building_container.get_children():
			if child.scene_file_path == gate_scene.resource_path: 
				print("Gate already exists! cannot build another.")
				return

	if not gate_scene: return
		
	var gate_instance = gate_scene.instantiate()
	gate_instance.position = terrain_layer.map_to_local(grid_pos)
	
	# Scaling Logic
	var target_width = 100.0 
	if "texture" in gate_instance and gate_instance.texture:
		var tex = gate_instance.texture
		var scale_factor = target_width / tex.get_width()
		gate_instance.scale = Vector2(scale_factor, scale_factor)
	else:
		var sprite = gate_instance.get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			var scale_factor = target_width / sprite.texture.get_width()
			gate_instance.scale = Vector2(scale_factor, scale_factor)
			
	gate_instance.position.y += 24
	gate_instance.position.x += 5

	building_container.add_child(gate_instance)
	print("Placed Gate at ", grid_pos)
	
	# Register Gate Position and Start Spawning
	if grid_pos not in gate_positions:
		gate_positions.append(grid_pos)
		
	if spawn_timer.is_stopped():
		spawn_timer.start()
	
	# Initial Spawn
	spawn_peep(grid_pos)

func _setup_building_container():
	building_container = Node2D.new()
	building_container.name = "Buildings"
	building_container.y_sort_enabled = true
	add_child(building_container)

func _setup_cursor():
	cursor_sprite = Sprite2D.new()
	var tex = load("res://assets/tile_select.png")
	if tex:
		cursor_sprite.texture = tex
		cursor_sprite.offset = Vector2(0, -8) 
		cursor_sprite.modulate = Color(1, 1, 1, 0.5)
		cursor_sprite.z_index = 100
		add_child(cursor_sprite)
	else:
		push_warning("Cursor texture not found")

func _set_mode(mode: int):
	current_mode = mode
	print("Switched to mode: ", mode)

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		if current_mode != GameMode.VIEW:
			_set_mode(GameMode.VIEW)
			if hud and hud.has_method("update_mode_display"):
				hud.update_mode_display(GameMode.VIEW)

func generate_flat_terrain():
	print("Generating Terrain...")
	terrain_layer.clear()
	for x in range(map_size.x):
		for y in range(map_size.y):
			terrain_layer.set_cell(Vector2i(x, y), SOURCE_ID, TILE_GRASS)
	print("Terrain Generation Complete.")

func set_tile_height(_grid_pos: Vector2i, _height: int):
	pass
