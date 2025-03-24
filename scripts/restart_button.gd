extends Button

func _ready():
	# Connect pressed signal to restart function
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed():
	# Get reference to the game manager (parent node)
	var game_manager = get_node("/root/Game")
	if game_manager:
		game_manager.restart_game()
	else:
		print("Could not find Game node")
		
	# Add mobile-specific feedback
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Add visual feedback for mobile devices
		modulate = Color(0.8, 0.8, 0.8)  # Slightly darken button
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)  # Reset color
