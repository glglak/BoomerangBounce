extends Node
class_name GameManager

# Score settings
var current_score = 0
var high_score = 0
var score_increment_rate = 1  # Points per second (much slower)
var game_active = false
var game_time = 0.0

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
@onready var left_button = $Controls/LeftButton
@onready var right_button = $Controls/RightButton
@onready var jump_button = $Controls/JumpButton
@onready var ground = $Ground  # Reference to the ground visual

func _ready():
	randomize()
	
	# Load high score
	load_high_score()
	
	# Connect signals
	player.connect("player_hit", Callable(self, "_on_player_hit"))
	restart_button.connect("pressed", Callable(self, "restart_game"))
	gameover_restart_button.connect("pressed", Callable(self, "restart_game"))
	left_button.connect("pressed", Callable(self, "_on_left_button_pressed"))
	right_button.connect("pressed", Callable(self, "_on_right_button_pressed"))
	jump_button.connect("pressed", Callable(self, "_on_jump_button_pressed"))
	
	# Setup input mapping for restarting
	if not InputMap.has_action("restart"):
		InputMap.add_action("restart")
		var r_key = InputEventKey.new()
		r_key.keycode = KEY_R
		InputMap.action_add_event("restart", r_key)
	
	# Start game after a short delay
	game_over_panel.visible = false
	await get_tree().create_timer(0.5).timeout
	start_game()

func _process(delta):
	if not game_active:
		if Input.is_action_just_pressed("restart"):
			restart_game()
		return
	
	# Increment score based on time, but much more slowly
	game_time += delta
	
	# Score increments faster as game progresses (to reward survival)
	var difficulty_factor = min(game_time / 60.0, 1.0)
	var current_score_rate = score_increment_rate + (difficulty_factor * 2)
	
	var new_score = int(game_time * current_score_rate) + int(game_time / 5)
	if new_score > current_score:
		current_score = new_score
		update_score_display()

func start_game():
	# Reset game state
	current_score = 0
	game_time = 0
	game_active = true
	game_over_panel.visible = false
	
	# Reset player
	player.reset()
	
	# Start obstacle spawning
	obstacle_manager.start()
	
	# Update UI
	update_score_display()
	update_high_score_display()

func restart_game():
	start_game()

func _on_player_hit():
	# Player hit an obstacle - game over
	game_active = false
	obstacle_manager.stop()
	
	# Check for high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
	
	# Update UI
	update_high_score_display()
	game_over_panel.visible = true
	$UI/GameOverPanel/ScoreLabel.text = "Score: " + str(current_score)

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

# Touch control handler functions
func _on_left_button_pressed():
	player.move_left()

func _on_right_button_pressed():
	player.move_right()

func _on_jump_button_pressed():
	player.try_jump()
