extends CanvasLayer
class_name HUD

# HUD.gd
# Manages the UI overlay and signals mode changes

signal mode_requested(mode_type: int)

enum GameMode {
	VIEW = 0,
	BUILD_ROAD = 1,
	DEMOLISH = 2,
	BUILD_GATE = 3
}

var build_btn: Button
var demolish_btn: Button
var current_mode_label: Label

func _ready():
	_setup_ui()

func _setup_ui():
	# Root Control
	var control = Control.new()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE # Let clicks pass through to game
	add_child(control)
	
	# Bottom Left Container
	var container = HBoxContainer.new()
	container.position = Vector2(20, 720 - 60) # Bottom left with padding (assuming 720p)
	# Better: Use anchors
	container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	container.set_position(Vector2(20, -60)) # Offset from bottom left anchor? 
	# Anchors are tricky in code without firing layout update.
	# Let's use simple positioning for MVP or correct anchors.
	# Proper Anchor setup:
	# container.layout_mode = 1 (Anchors)
	# container.anchors_preset = Control.PRESET_BOTTOM_LEFT
	# container.position = Vector2(20, 660) # Fallback
	add_child(container)
	
	# Styles
	var btn_size = Vector2(120, 40)
	
	# Build Road Button
	build_btn = Button.new()
	build_btn.text = "Build Road"
	build_btn.custom_minimum_size = btn_size
	build_btn.pressed.connect(func(): _on_mode_btn_pressed(GameMode.BUILD_ROAD))
	container.add_child(build_btn)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	container.add_child(spacer)
	
	# Demolish Button
	demolish_btn = Button.new()
	demolish_btn.text = "Demolish"
	demolish_btn.custom_minimum_size = btn_size
	demolish_btn.pressed.connect(func(): _on_mode_btn_pressed(GameMode.DEMOLISH))
	container.add_child(demolish_btn)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(20, 0)
	container.add_child(spacer2)
	
	# Gate Button
	var gate_btn = Button.new()
	gate_btn.text = "Build Gate"
	gate_btn.custom_minimum_size = btn_size
	gate_btn.pressed.connect(func(): _on_mode_btn_pressed(GameMode.BUILD_GATE))
	container.add_child(gate_btn)
	
	# Mode Indicator Label (Top Center)
	current_mode_label = Label.new()
	current_mode_label.text = "Mode: VIEW"
	current_mode_label.label_settings = LabelSettings.new()
	current_mode_label.label_settings.font_size = 24
	current_mode_label.label_settings.outline_size = 4
	current_mode_label.label_settings.outline_color = Color.BLACK
	current_mode_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	current_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(current_mode_label)

func _on_mode_btn_pressed(mode: int):
	# Update Button States (Visual feedback)
	mode_requested.emit(mode)
	update_mode_display(mode)

func update_mode_display(mode: int):
	match mode:
		GameMode.VIEW:
			current_mode_label.text = "Mode: VIEW (Pan/Zoom)"
			build_btn.disabled = false
			demolish_btn.disabled = false
		GameMode.BUILD_ROAD:
			current_mode_label.text = "Mode: BUILD ROAD (Click to build, ESC to cancel)"
			build_btn.disabled = true
			demolish_btn.disabled = false
		GameMode.DEMOLISH:
			current_mode_label.text = "Mode: DEMOLISH (Click to remove, ESC to cancel)"
			build_btn.disabled = false
			demolish_btn.disabled = true
