extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# Get reference to the game manager (parent node)
	var game_manager = get_node("/root/Game")
	if game_manager:
		game_manager.restart_game()
	else:
		print("Could not find Game node")
