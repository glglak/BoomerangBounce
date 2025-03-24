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
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		is_mobile = true
		# Use explicit screen orientation setting - 1 is portrait
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		print("Setting screen orientation to portrait")
	
	# Set up controls based on platform
	setup_controls()
	
	# Connect button signals
	jump_button.connect("pressed", Callable(self, "_on_jump_button_pressed"))
	
	# Load high score
	load_high_score()
	
	# Connect signals
	player.connect("player_hit", Callable(self, "_on_player_hit"))
	player.connect("jump_performed", Callable(self, "_on_player_jump"))
	obstacle_manager.connect("obstacle_passed", Callable(self, "_on_obstacle_passed"))
	restart_button.connect("pressed", Callable(self, "restart_game"))
	gameover_restart_button.connect("pressed", Callable(self, "restart_game"))
	
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
	
	# Start game after a short delay
	game_over_panel.visible = false
	await get_tree().create_timer(0.5).timeout
	start_game()

func setup_controls():
	# Make controls visible and positioned properly for mobile
	controls_container.visible = true
	
	# Set up help label
	if is_mobile:
		help_label.text = "Tap left/right side of screen\nto jump in that direction"
	else:
		help_label.text = "Tap left/right side of screen\nor use Space to jump"

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

func _on_jump_button_pressed():
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

func restart_game():
	# Stop any playing sounds
	if game_over_sound and game_over_sound.playing:
		game_over_sound.stop()
	if milestone_sound and milestone_sound.playing:
		milestone_sound.stop()
	if wesopeso_sound and wesopeso_sound.playing:
		wesopeso_sound.stop()
		
	start_game()

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
	if is_mobile and event is InputEventScreenTouch and event.pressed and game_active:
		var screen_width = get_viewport().size.x
		
		# Only handle touch events in the game area (not on UI controls)
		if event.position.y < get_viewport().size.y - 120:  # Above control area
			if event.position.x < screen_width / 2:
				player.set_target_position(max(player.global_position.x - 170, player.screen_margin)) 
				player.try_jump()
			else:
				player.set_target_position(min(player.global_position.x + 170, screen_width - player.screen_margin))
				player.try_jump()
