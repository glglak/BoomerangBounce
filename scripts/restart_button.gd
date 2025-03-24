extends Button

var is_mobile = false

func _ready():
	# Check platform
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Ensure button is properly configured for input
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Check if signal is already connected to avoid duplicate connections
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	# Make button larger on mobile for easier touch interaction
	if is_mobile:
		custom_minimum_size = Vector2(140, 60)
	
	print("Restart button initialized")

func _on_pressed():
	print("Restart button pressed")
	
	# Get reference to the game manager (parent node)
	var game_manager = get_node("/root/Game")
	if game_manager:
		# Add visual feedback for button press
		if is_mobile:
			modulate = Color(0.8, 0.8, 0.8)  # Slightly darken button
			await get_tree().create_timer(0.1).timeout
			modulate = Color(1, 1, 1)  # Reset color
		
		# Call restart function on game manager
		game_manager.restart_game()
	else:
		push_error("Could not find Game node")
		print("Could not find Game node")
