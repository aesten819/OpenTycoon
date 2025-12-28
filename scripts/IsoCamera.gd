extends Camera2D

# IsoCamera.gd
# Handles panning and zooming for the isometric view

@export var speed: float = 500.0
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_speed: float = 0.1

var _target_zoom: float = 1.0
var _is_dragging: bool = false

func _ready():
	_target_zoom = zoom.x

func _process(delta):
	_handle_keyboard_input(delta)
	_smooth_zoom(delta)

func _handle_keyboard_input(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		position += velocity.normalized() * speed * delta / zoom.x

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = min(_target_zoom + zoom_speed, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = max(_target_zoom - zoom_speed, min_zoom)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = event.pressed
			
	elif event is InputEventMouseMotion and _is_dragging:
		position -= event.relative / zoom

func _smooth_zoom(delta):
	zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), delta * 10)
