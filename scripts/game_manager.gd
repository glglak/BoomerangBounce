extends Node
class_name GameManager

# Game state signals
signal game_over(score: int)
signal score_updated(new_score: int)

# Game state variables
var current_score: int = 0
var high_score: int = 0
var game_active: bool = false

# Path for saving high score
const SAVE_FILE_PATH = "user://highscore.save"

# References to other nodes
@onready var player: Player = $Player
@onready var obstacle_manager: ObstacleManager = $ObstacleManager
@onready var score_label: Label = $UI/ScoreLabel
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var controls: ControlsManager = $Controls

func _ready() -> void:
	# Load high score
	load_high_score()
	
	# Connect signals
	player.connect("player_hit", _on_player_hit)
	
	# Connect control signals to player
	controls.connect("move_left_pressed", _on_move_left_pressed)
	controls.connect("move_left_released", _on_move_left_released)
	controls.connect("move_right_pressed", _on_move_right_pressed)
	controls.connect("move_right_released", _on_move_right_released)
	controls.connect("jump_pressed", _on_jump_pressed)
	
	# Set up input actions for keyboard controls as well
	_setup_input_actions()
	
	# Update UI
	update_score_display()
	update_high_score_display()
	
	# Automatically start the game after a short delay
	await get_tree().create_timer(0.5).timeout
	start_game()

func _setup_input_actions() -> void:
	# Create input mappings if they don't exist
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var left_key = InputEventKey.new()
		left_key.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", left_key)
		
		var a_key = InputEventKey.new()
		a_key.keycode = KEY_A
		InputMap.action_add_event("move_left", a_key)
	
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var right_key = InputEventKey.new()
		right_key.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", right_key)
		
		var d_key = InputEventKey.new()
		d_key.keycode = KEY_D
		InputMap.action_add_event("move_right", d_key)
	
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var space_key = InputEventKey.new()
		space_key.keycode = KEY_SPACE
		InputMap.action_add_event("jump", space_key)
		
		var w_key = InputEventKey.new()
		w_key.keycode = KEY_W
		InputMap.action_add_event("jump", w_key)
		
		var up_key = InputEventKey.new()
		up_key.keycode = KEY_UP
		InputMap.action_add_event("jump", up_key)

func start_game() -> void:
	# Reset game state
	current_score = 0
	game_active = true
	
	# Update UI
	update_score_display()
	
	# Start countdown before beginning gameplay
	countdown_timer.start()
	
	# Play start animation if available
	animation_player.play("game_start")

func _on_countdown_timer_timeout() -> void:
	# Start the obstacle spawning
	obstacle_manager.start()

func _on_player_hit() -> void:
	# Player was hit by obstacle - game over
	game_active = false
	obstacle_manager.stop()
	
	# Check for high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
		update_high_score_display()
	
	# Emit game over signal
	emit_signal("game_over", current_score)
	
	# Transition to Game Over scene after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func update_score(new_score: int) -> void:
	current_score = new_score
	emit_signal("score_updated", current_score)
	update_score_display()

func update_score_display() -> void:
	score_label.text = "Score: %d" % current_score

func update_high_score_display() -> void:
	high_score_label.text = "High Score: %d" % high_score

func save_high_score() -> void:
	var save_data = {
		"high_score": high_score
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score

# Controls handlers
func _on_move_left_pressed() -> void:
	player.move_left()

func _on_move_left_released() -> void:
	player.stop_moving()

func _on_move_right_pressed() -> void:
	player.move_right()

func _on_move_right_released() -> void:
	player.stop_moving()

func _on_jump_pressed() -> void:
	player.try_jump()
