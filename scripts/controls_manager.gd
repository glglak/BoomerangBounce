extends CanvasLayer
class_name ControlsManager

# Signals to connect to player
signal move_left_pressed
signal move_left_released
signal move_right_pressed
signal move_right_released
signal jump_pressed
signal set_target_position(pos_x)  # Signal to set exact target position

# Touch state
var left_touch_idx: int = -1
var right_touch_idx: int = -1
var jump_touch_idx: int = -1
var directional_jump_touch_idx: Array = []  # Store indexes for directional jumps

# Button references
@onready var left_button: TextureButton = $LeftButton
@onready var right_button: TextureButton = $RightButton
@onready var jump_button: TextureButton = $JumpButton

# Helper label for debugging
@onready var help_label: Label = $HelpLabel

# Debounce system
var jump_debounce_timer = null
var jump_cooldown = 0.03  # Shorter cooldown for more responsive jumps

# Screen division for touch zones
var left_zone_width = 0.33  # Left third of screen
var right_zone_width = 0.33  # Right third of screen

func _ready() -> void:
	# Create debounce timer for jump
	jump_debounce_timer = Timer.new()
	jump_debounce_timer.one_shot = true
	jump_debounce_timer.wait_time = jump_cooldown
	jump_debounce_timer.autostart = false
	add_child(jump_debounce_timer)
	
	# Ensure buttons are properly sized and visible
	_configure_buttons_for_mobile()
	
	# Connect button signals with more reliable method
	if left_button != null:
		if left_button.button_down.is_connected(_on_left_button_down):
			left_button.button_down.disconnect(_on_left_button_down)
		left_button.button_down.connect(_on_left_button_down)
		
		if left_button.button_up.is_connected(_on_left_button_up):
			left_button.button_up.disconnect(_on_left_button_up)
		left_button.button_up.connect(_on_left_button_up)
	
	if right_button != null:
		if right_button.button_down.is_connected(_on_right_button_down):
			right_button.button_down.disconnect(_on_right_button_down)
		right_button.button_down.connect(_on_right_button_down)
		
		if right_button.button_up.is_connected(_on_right_button_up):
			right_button.button_up.disconnect(_on_right_button_up)
		right_button.button_up.connect(_on_right_button_up)
	
	if jump_button != null:
		if jump_button.button_down.is_connected(_on_jump_button_down):
			jump_button.button_down.disconnect(_on_jump_button_down)
		jump_button.button_down.connect(_on_jump_button_down)
	
	# Make sure help text is visible
	if help_label:
		help_label.visible = true
		
	print("Controls manager initialized with improved mobile support")

func _configure_buttons_for_mobile() -> void:
	# Make buttons more prominent and easier to tap
	if left_button:
		left_button.modulate = Color(1.0, 1.0, 1.0, 0.8)  # Slightly transparent for visibility
		left_button.mouse_filter = Control.MOUSE_FILTER_STOP
		left_button.focus_mode = Control.FOCUS_ALL
		left_button.ignore_texture_size = true
		left_button.stretch_mode = TextureButton.STRETCH_SCALE
		left_button.custom_minimum_size = Vector2(150, 150)  # Larger touch target
	
	if right_button:
		right_button.modulate = Color(1.0, 1.0, 1.0, 0.8)  # Slightly transparent for visibility
		right_button.mouse_filter = Control.MOUSE_FILTER_STOP
		right_button.focus_mode = Control.FOCUS_ALL
		right_button.ignore_texture_size = true
		right_button.stretch_mode = TextureButton.STRETCH_SCALE
		right_button.custom_minimum_size = Vector2(150, 150)  # Larger touch target
	
	if jump_button:
		jump_button.modulate = Color(1.0, 1.0, 1.0, 0.8)  # Slightly transparent for visibility
		jump_button.mouse_filter = Control.MOUSE_FILTER_STOP
		jump_button.focus_mode = Control.FOCUS_ALL
		jump_button.ignore_texture_size = true
		jump_button.stretch_mode = TextureButton.STRETCH_SCALE
		jump_button.custom_minimum_size = Vector2(180, 180)  # Larger touch target

func _input(event: InputEvent) -> void:
	# Handle touch input with improved detection
	if event is InputEventScreenTouch:
		_handle_touch_event(event)
		
	# Ensure input event gets processed correctly
	if event:
		get_viewport().set_input_as_handled()

func _handle_touch_event(event: InputEventScreenTouch) -> void:
	var touch_position = event.position
	
	# Check which control area was touched
	if event.pressed:
		# New touch started
		if _is_touch_in_left_control(touch_position):
			print("Left control touched at " + str(touch_position))
			left_touch_idx = event.index
			emit_signal("move_left_pressed")
			get_viewport().set_input_as_handled()
			
		elif _is_touch_in_right_control(touch_position):
			print("Right control touched at " + str(touch_position))
			right_touch_idx = event.index
			emit_signal("move_right_pressed")
			get_viewport().set_input_as_handled()
			
		elif _is_touch_in_jump_control(touch_position):
			print("Jump control touched at " + str(touch_position))
			jump_touch_idx = event.index
			# Only allow jump if not in cooldown
			if jump_debounce_timer.time_left <= 0:
				emit_signal("jump_pressed")
				jump_debounce_timer.start()
			get_viewport().set_input_as_handled()
			
		else:
			# For touches elsewhere on screen, direct the jump to that position
			print("Screen touch for directional jump at " + str(touch_position))
			directional_jump_touch_idx.append(event.index)
			
			# Signal player to move toward touch position first
			emit_signal("set_target_position", touch_position.x)
			
			# Then signal to jump immediately (no delay)
			if jump_debounce_timer.time_left <= 0:
				emit_signal("jump_pressed")
				jump_debounce_timer.start(0.01)  # Very short cooldown for responsive jumps
			
			# Register input actions to ensure compatibility
			Input.action_press("jump")
			
			# Auto-release jump after short time
			await get_tree().create_timer(0.02).timeout
			Input.action_release("jump")
			get_viewport().set_input_as_handled()
	else:
		# Touch ended
		if event.index == left_touch_idx:
			left_touch_idx = -1
			emit_signal("move_left_released")
		elif event.index == right_touch_idx:
			right_touch_idx = -1
			emit_signal("move_right_released")
		elif event.index == jump_touch_idx:
			jump_touch_idx = -1
		elif event.index in directional_jump_touch_idx:
			directional_jump_touch_idx.erase(event.index)

func _is_touch_in_left_control(pos: Vector2) -> bool:
	# Use both button hit detection and screen zone detection for better mobile experience
	if left_button and left_button.get_global_rect().has_point(pos):
		return true
		
	# Additional check for left third of screen for easy jumping
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	return pos.x < screen_width * left_zone_width and pos.y > screen_height * 0.5

func _is_touch_in_right_control(pos: Vector2) -> bool:
	# Use both button hit detection and screen zone detection for better mobile experience
	if right_button and right_button.get_global_rect().has_point(pos):
		return true
		
	# Additional check for right third of screen for easy jumping
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	return pos.x > screen_width * (1.0 - right_zone_width) and pos.y > screen_height * 0.5

func _is_touch_in_jump_control(pos: Vector2) -> bool:
	return jump_button and jump_button.get_global_rect().has_point(pos)

# Button signal handlers
func _on_left_button_down() -> void:
	print("Left button pressed")
	emit_signal("move_left_pressed")
	
	# Set target position immediately with move_left
	var viewport_rect = get_viewport_rect().size
	emit_signal("set_target_position", viewport_rect.x * 0.25)  # 1/4 of the screen from left
	
	# Also signal jump for better mobile experience
	if jump_debounce_timer.time_left <= 0:
		emit_signal("jump_pressed")
		jump_debounce_timer.start(0.01)  # Very short cooldown
	
	# Also register input action for player script to pick up
	Input.action_press("move_left")
	Input.action_press("jump")
	
	# Auto-release jump after short time
	await get_tree().create_timer(0.02).timeout
	Input.action_release("jump")

func _on_left_button_up() -> void:
	emit_signal("move_left_released")
	
	# Release input action
	Input.action_release("move_left")

func _on_right_button_down() -> void:
	print("Right button pressed")
	emit_signal("move_right_pressed")
	
	# Set target position immediately with move_right
	var viewport_rect = get_viewport_rect().size
	emit_signal("set_target_position", viewport_rect.x * 0.75)  # 3/4 of the screen from left
	
	# Also signal jump for better mobile experience
	if jump_debounce_timer.time_left <= 0:
		emit_signal("jump_pressed")
		jump_debounce_timer.start(0.01)  # Very short cooldown
	
	# Also register input action for player script to pick up
	Input.action_press("move_right")
	Input.action_press("jump")
	
	# Auto-release jump after short time
	await get_tree().create_timer(0.02).timeout
	Input.action_release("jump")

func _on_right_button_up() -> void:
	emit_signal("move_right_released")
	
	# Release input action
	Input.action_release("move_right")

func _on_jump_button_down() -> void:
	print("Jump button pressed")
	
	# Only allow jump if not in cooldown
	if jump_debounce_timer.time_left <= 0:
		# Jump in place (no horizontal movement)
		emit_signal("jump_pressed")
		
		# Also register input action for player script to pick up
		Input.action_press("jump")
		
		# Start debounce timer
		jump_debounce_timer.start(0.01)  # Very short cooldown for responsive jumps
		
		# Auto-release the jump input after a short time
		await get_tree().create_timer(0.02).timeout
		Input.action_release("jump")
