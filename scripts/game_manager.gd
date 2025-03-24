extends Node
class_name GameManager

# Score settings
var current_score = 0
var high_score = 0
var game_active = false
var game_time = 0.0
var last_milestone = 0  # Track last milestone for sound effects

# Platform detection variables
var is_mobile = false
var restart_in_progress = false  # Flag to prevent multiple restarts

# Path for saving high score
const SAVE_FILE_PATH = "user://highscore.save"

# Node references
@onready var player = $Player
@onready var obstacle_manager = $ObstacleManager
@onready var score_label = $UI/ScoreLabel
@onready var high_score_label = $UI/HighScoreLabel 
@onready var game_over_panel = $UI/GameOverPanel
@onready var restart_button = $UI/RestartButton
@onready var gameover_restart_button = $UI/GameOverPanel/RestartButton
@onready var jump_button = $Controls/JumpButton
@onready var help_label = $Controls/HelpLabel
@onready var ground = $Ground  # Reference to the ground visual
@onready var controls_container = $Controls  # Container for all controls

# Audio references
@onready var background_music = $Audio/BackgroundMusic
@onready var jump_sound = $Audio/JumpSound
@onready var score_sound = $Audio/ScoreSound
@onready var milestone_sound = $Audio/MilestoneSound
@onready var wesopeso_sound = $Audio/WesoPesoSound
@onready var game_over_sound = $Audio/GameOverSound

# Background references
@onready var background_1 = $Backgrounds/Background1
@onready var background_2 = $Backgrounds/Background2
@onready var background_3 = $Backgrounds/Background3
@onready var background_4 = $Backgrounds/Background4
@onready var background_5 = $Backgrounds/Background5

func _ready():
	randomize()
	
	# Force portrait orientation for mobile
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	if is_mobile:
		# Use explicit screen orientation setting - 1 is portrait
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		print("Setting screen orientation to portrait")
	
	# Set up controls based on platform
	setup_controls()
	
	# Connect button signals directly - this is the key fix for button functionality
	direct_connect_button_signals()
	
	# Load high score
	load_high_score()
	
	# Connect signals
	player.connect("player_hit", Callable(self, "_on_player_hit"))
	player.connect("jump_performed", Callable(self, "_on_player_jump"))
	obstacle_manager.connect("obstacle_passed", Callable(self, "_on_obstacle_passed"))
	
	# Pass player reference to obstacle manager
	obstacle_manager.set_player_reference(player)
	
	# Setup input mapping for restarting
	if not InputMap.has_action("restart"):
		InputMap.add_action("restart")
		var r_key = InputEventKey.new()
		r_key.keycode = KEY_R
		InputMap.action_add_event("restart", r_key)
	
	# Initialize backgrounds
	_set_background_for_score(0)
	
	# Reset restart flag
	restart_in_progress = false
	
	# Start game after a short delay
	game_over_panel.visible = false
	await get_tree().create_timer(0.5).timeout
	start_game()

func direct_connect_button_signals():
	# This method ensures buttons are properly connected with direct callable references
	
	# Configure restart button
	if restart_button:
		# Ensure button is visible and usable
		restart_button.flat = false
		restart_button.focus_mode = Control.FOCUS_ALL
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Disconnect any existing signals to prevent duplicates
		if restart_button.pressed.is_connected(Callable(self, "restart_game")):
			restart_button.pressed.disconnect(Callable(self, "restart_game"))
		
		# Connect directly using callable
		restart_button.pressed.connect(Callable(self, "restart_game"))
	
	# Configure game over restart button
	if gameover_restart_button:
		# Ensure button is visible and usable
		gameover_restart_button.flat = false
		gameover_restart_button.focus_mode = Control.FOCUS_ALL
		gameover_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Disconnect any existing signals to prevent duplicates
		if gameover_restart_button.pressed.is_connected(Callable(self, "restart_game")):
			gameover_restart_button.pressed.disconnect(Callable(self, "restart_game"))
		
		# Connect directly using callable
		gameover_restart_button.pressed.connect(Callable(self, "restart_game"))
	
	# Configure jump button
	if jump_button:
		# Ensure button is visible and usable
		jump_button.flat = false
		jump_button.focus_mode = Control.FOCUS_ALL
		jump_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Disconnect any existing signals to prevent duplicates
		if jump_button.pressed.is_connected(Callable(self, "_on_jump_button_pressed")):
			jump_button.pressed.disconnect(Callable(self, "_on_jump_button_pressed"))
		
		# Connect directly using callable
		jump_button.pressed.connect(Callable(self, "_on_jump_button_pressed"))
	
	print("Button signals directly connected")

func setup_controls():
	# Make controls visible and positioned properly for mobile
	controls_container.visible = true
	
	# Set up help label
	if is_mobile:
		help_label.text = "Tap left/right side of screen\nto jump in that direction"
	else:
		help_label.text = "Tap left/right side of screen\nor use Space to jump"
	
	# Adjust button appearance and position based on platform
	if restart_button:
		# Enable button processing
		restart_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Ensure the restart button is positioned correctly for the device
		if is_mobile:
			# For mobile, make larger touch targets
			restart_button.custom_minimum_size = Vector2(140, 80)  # Larger button for touch
		else:
			# For desktop, standard size
			restart_button.custom_minimum_size = Vector2(100, 40)
	
	if gameover_restart_button:
		# Enable button processing
		gameover_restart_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		gameover_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Make button larger on mobile
		if is_mobile:
			gameover_restart_button.custom_minimum_size = Vector2(200, 80)
	
	if jump_button and is_mobile:
		jump_button.custom_minimum_size = Vector2(140, 80)
		jump_button.mouse_filter = Control.MOUSE_FILTER_STOP
		jump_button.flat = false

func _process(delta):
	if not game_active:
		if Input.is_action_just_pressed("restart"):
			restart_game()
		return
	
	# Update game time (used for difficulty scaling)
	game_time += delta
	
	# Input handling for keyboard
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		_on_jump_button_pressed()

func _input(event):
	# Handle direct input for buttons on mobile
	if is_mobile and event is InputEventScreenTouch and event.pressed:
		# Handle restart button when game over
		if not game_active and game_over_panel.visible:
			if gameover_restart_button and gameover_restart_button.get_global_rect().has_point(event.position):
				restart_game()
				return true
		# Handle restart button during gameplay
		elif restart_button and restart_button.get_global_rect().has_point(event.position):
			restart_game()
			return true
		# Handle jump button
		elif jump_button and jump_button.get_global_rect().has_point(event.position):
			_on_jump_button_pressed()
			return true

func _on_jump_button_pressed():
	print("Jump button pressed function called")
	if game_active and player:
		player.try_jump()

func _on_obstacle_passed():
	# Increment score when an obstacle is passed
	current_score += 1
	
	# Play score sound
	if score_sound:
		score_sound.play()
	
	# Check for milestone
	if int(current_score / 10) > int(last_milestone / 10):
		_handle_milestone(current_score)
	
	# Update display
	update_score_display()

func start_game():
	# Reset game state
	current_score = 0
	game_time = 0
	game_active = true
	game_over_panel.visible = false
	last_milestone = 0
	
	# Reset player
	player.reset()
	
	# Start obstacle spawning
	obstacle_manager.start()
	
	# Set initial background
	_set_background_for_score(0)
	
	# Start background music
	if background_music:
		background_music.play()
	
	# Update UI
	update_score_display()
	update_high_score_display()

# This is the function that gets called both from the UI button and the keyboard R key
func restart_game():
	print("Restart game called!")  # Debug info
	
	# Prevent multiple simultaneous restarts
	if restart_in_progress:
		print("Restart already in progress, ignoring duplicate call")
		return
	
	restart_in_progress = true
	
	# Visual feedback for mobile
	if is_mobile:
		if game_over_panel.visible and gameover_restart_button:
			gameover_restart_button.modulate = Color(0.8, 0.8, 0.8)
			await get_tree().create_timer(0.1).timeout
			gameover_restart_button.modulate = Color(1, 1, 1)
		elif restart_button:
			restart_button.modulate = Color(0.8, 0.8, 0.8)
			await get_tree().create_timer(0.1).timeout
			restart_button.modulate = Color(1, 1, 1)
	
	# Stop any playing sounds
	if game_over_sound and game_over_sound.playing:
		game_over_sound.stop()
	if milestone_sound and milestone_sound.playing:
		milestone_sound.stop()
	if wesopeso_sound and wesopeso_sound.playing:
		wesopeso_sound.stop()
	
	start_game()
	
	# Reset flag after a delay to prevent rapid restart clicking
	await get_tree().create_timer(0.5).timeout
	restart_in_progress = false

func _on_player_hit():
	# Player hit an obstacle - game over
	game_active = false
	obstacle_manager.stop()
	
	# Stop background music
	if background_music:
		background_music.stop()
		
	# Play game over sound
	if game_over_sound:
		game_over_sound.play()
	
	# Check for high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
	
	# Update UI
	update_high_score_display()
	game_over_panel.visible = true
	$UI/GameOverPanel/ScoreLabel.text = "Score: " + str(current_score)

func _handle_milestone(score):
	# Handle milestone sounds and background changes
	var milestone = int(score / 10)
	
	if milestone != last_milestone:
		last_milestone = milestone
		
		# Update background based on score
		_set_background_for_score(score)
		
		# Play appropriate milestone sound
		if milestone <= 4:  # 10, 20, 30, 40 points
			if milestone_sound:
				milestone_sound.play()
		else:  # 50, 60, 70+ points
			if wesopeso_sound:
				wesopeso_sound.play()

func _set_background_for_score(score):
	# Hide all backgrounds
	if background_1: background_1.visible = false
	if background_2: background_2.visible = false
	if background_3: background_3.visible = false
	if background_4: background_4.visible = false
	if background_5: background_5.visible = false
	
	# Show appropriate background based on score
	if score < 10:
		if background_1: background_1.visible = true
	elif score < 20:
		if background_2: background_2.visible = true
	elif score < 30:
		if background_3: background_3.visible = true
	elif score < 40:
		if background_4: background_4.visible = true
	else:
		if background_5: background_5.visible = true

func _on_player_jump():
	# Play jump sound
	if jump_sound:
		jump_sound.play()

func update_score_display():
	score_label.text = "Score: " + str(current_score)

func update_high_score_display():
	high_score_label.text = "High Score: " + str(high_score)

func save_high_score():
	var save_data = {"high_score": high_score}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score
	
	update_high_score_display()

# Function for input events directly from the screen
func _unhandled_input(event):
	# Handle raw screen touches for jumping in direction
	if event is InputEventScreenTouch and event.pressed and game_active and player:
		var screen_width = get_viewport().size.x
		var screen_height = get_viewport().size.y
		
		# Only handle touch events in the game area (not on UI controls)
		if event.position.y < screen_height - 150:  # Above control area
			# Check if the touch is on any UI elements first
			if restart_button and restart_button.get_global_rect().has_point(event.position):
				# Touch is on restart button
				return
			
			if jump_button and jump_button.get_global_rect().has_point(event.position):
				# Touch is on jump button
				return
				
			# Handle touch for movement if not on UI elements
			if event.position.x < screen_width / 2:
				# Left side jump
				player.move_left()
				player.try_jump()
			else:
				# Right side jump
				player.move_right()
				player.try_jump()
	
	# Support restarting via keyboard or touch on game over
	elif event is InputEventScreenTouch and event.pressed and not game_active:
		if game_over_panel.visible:
			# Check if touch is on game over restart button to avoid double triggers
			var restart_button_rect = gameover_restart_button.get_global_rect() if gameover_restart_button else Rect2()
			if not restart_button_rect.has_point(event.position):
				# Only restart if touching outside of UI elements
				restart_game()
