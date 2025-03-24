extends Control

# References to UI elements
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton
@onready var high_score_label = $HighScoreLabel

# Save file path - same as in game_manager.gd
const SAVE_FILE_PATH = "user://highscore.save"

# Platform detection variable
var is_mobile = false

func _ready():
	# Detect platform type
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Force portrait orientation for mobile
	if is_mobile:
		# Use explicit screen orientation setting - 1 is portrait
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		print("Setting screen orientation to portrait from main menu")
		
		# Adjust button sizes for mobile
		_adjust_buttons_for_mobile()
	
	# Connect button signals using direct callables for more reliable connections
	if play_button:
		# Disconnect any existing signals to avoid duplicates
		if play_button.pressed.is_connected(Callable(self, "_on_play_button_pressed")):
			play_button.pressed.disconnect(Callable(self, "_on_play_button_pressed"))
		
		# Connect with direct callable reference
		play_button.pressed.connect(Callable(self, "_on_play_button_pressed"))
		
		# Enable button input processing
		play_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		play_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if quit_button:
		# Disconnect any existing signals to avoid duplicates
		if quit_button.pressed.is_connected(Callable(self, "_on_quit_button_pressed")):
			quit_button.pressed.disconnect(Callable(self, "_on_quit_button_pressed"))
		
		# Connect with direct callable reference
		quit_button.pressed.connect(Callable(self, "_on_quit_button_pressed"))
		
		# Enable button input processing
		quit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Display high score
	load_and_display_high_score()
	
	print("Main menu buttons connected with direct callables")

func _adjust_buttons_for_mobile():
	if is_mobile:
		# Make buttons larger and more touch-friendly
		if play_button:
			play_button.custom_minimum_size = Vector2(200, 80)
			
		if quit_button:
			quit_button.custom_minimum_size = Vector2(200, 80)

func _on_play_button_pressed():
	print("Play button pressed")
	
	# Add visual feedback especially for mobile
	if is_mobile and play_button:
		play_button.modulate = Color(0.8, 0.8, 0.8)  # Slightly darken button
		await get_tree().create_timer(0.1).timeout
		play_button.modulate = Color(1, 1, 1)  # Reset color
	
	# Change to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit_button_pressed():
	print("Quit button pressed")
	
	# Add visual feedback especially for mobile
	if is_mobile and quit_button:
		quit_button.modulate = Color(0.8, 0.8, 0.8)  # Slightly darken button
		await get_tree().create_timer(0.1).timeout
		quit_button.modulate = Color(1, 1, 1)  # Reset color
		
	# Quit the game
	get_tree().quit()

func load_and_display_high_score():
	var high_score = 0
	
	# Try to load high score from file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score
	
	# Update the high score display
	high_score_label.text = "High Score: " + str(high_score)

# Support for keyboard navigation and alternative touch input
func _input(event):
	# Support keyboard navigation on desktop
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			_on_play_button_pressed()
	
	# Support tapping anywhere on screen to start (mobile-friendly)
	if is_mobile and event is InputEventScreenTouch and event.pressed:
		# Check if touch is not on quit button to avoid accidental quits
		if quit_button:
			var quit_button_rect = quit_button.get_global_rect()
			if not quit_button_rect.has_point(event.position):
				_on_play_button_pressed()
