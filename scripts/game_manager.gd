extends Node
class_name GameManager

# Game state signals
signal game_over(score: int)
signal score_updated(new_score: int)

# Game state variables
var current_score: int = 0
var high_score: int = 0
var difficulty_level: int = 1
var game_active: bool = false

# Speed increase factors
@export var base_speed_multiplier: float = 1.0
@export var speed_increase_per_level: float = 0.1
@export var max_difficulty: int = 20

# Path for saving high score
const SAVE_FILE_PATH = "user://highscore.save"

# References to other nodes (assigned in _ready)
@onready var player: Player = $Player
@onready var boomerang: Boomerang = $Boomerang
@onready var score_label: Label = $UI/ScoreLabel
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var throw_timer: Timer = $ThrowTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Load high score
	load_high_score()
	
	# Connect signals
	player.connect("player_hit", _on_player_hit)
	boomerang.connect("completed_loop", _on_boomerang_completed_loop)
	
	# Update UI
	update_score_display()
	update_high_score_display()
	
	# Start in inactive state
	game_active = false

func start_game() -> void:
	# Reset game state
	current_score = 0
	difficulty_level = 1
	game_active = true
	
	# Update UI
	update_score_display()
	
	# Start countdown before throwing first boomerang
	countdown_timer.start()
	
	# Play start animation if available
	animation_player.play("game_start")

func throw_boomerang() -> void:
	if not game_active:
		return
		
	# Calculate speed based on current difficulty
	var speed_multiplier = base_speed_multiplier + (difficulty_level - 1) * speed_increase_per_level
	
	# Throw the boomerang
	var throw_position = Vector2(0, player.global_position.y)
	boomerang.throw(throw_position, speed_multiplier)

func _on_player_hit() -> void:
	# Player was hit by boomerang - game over
	game_active = false
	
	# Check for high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
		update_high_score_display()
	
	# Emit game over signal
	emit_signal("game_over", current_score)

func _on_boomerang_completed_loop() -> void:
	# Player successfully dodged the boomerang
	current_score += 1
	emit_signal("score_updated", current_score)
	update_score_display()
	
	# Increase difficulty level (capped at max_difficulty)
	difficulty_level = min(difficulty_level + 1, max_difficulty)
	
	# Schedule next throw after a short delay
	throw_timer.start()

func _on_countdown_timer_timeout() -> void:
	# Initial countdown finished, throw first boomerang
	throw_boomerang()

func _on_throw_timer_timeout() -> void:
	# Delay between throws
	throw_boomerang()

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
