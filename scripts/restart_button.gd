extends Button

var is_mobile = false
var button_pressed = false  # Prevent double-presses

func _ready():
	# Check platform
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Ensure button is properly configured for input
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	flat = false  # Non-flat buttons are more visible on mobile
	focus_mode = Control.FOCUS_ALL  # Ensure button can be focused by input events
	
	# Reset button state
	button_pressed = false
	
	# Make button larger on mobile for easier touch interaction
	if is_mobile:
		custom_minimum_size = Vector2(140, 60)
	
	# Check if signal is already connected to avoid duplicate connections
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	print("Restart button initialized with proper configuration")

func _input(event):
	# Additional input handling for touch devices
	if is_mobile and event is InputEventScreenTouch:
		if event.pressed and not button_pressed:
			# Check if touch is on this button's area
			if get_global_rect().has_point(event.position):
				_on_pressed()
				return true  # Consume event

func _on_pressed():
	print("Restart button pressed")
	
	# Prevent double-presses
	if button_pressed:
		return
	
	button_pressed = true
	
	# Add visual feedback for button press
	if is_mobile:
		modulate = Color(0.8, 0.8, 0.8)  # Slightly darken button
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)  # Reset color
	
	# Get reference to the game manager (parent node)
	var game_manager = get_node("/root/Game")
	if game_manager:
		# Call restart function on game manager
		game_manager.restart_game()
		
		# Reset button state after a short delay
		await get_tree().create_timer(0.5).timeout
		button_pressed = false
	else:
		push_error("Could not find Game node")
		print("Could not find Game node")
		button_pressed = false
