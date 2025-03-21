extends Node
class_name GameManager

# Game state signals
signal game_over(score: int)
signal score_updated(new_score: int)

# Game state variables
var current_score: int = 0
var high_score: int = 0
var game_active: bool = false

# Game speed settings
@export var starting_speed: float = 300.0
@export var max_speed: float = 800.0
@export var speed_increase_per_second: float = 5.0
var current_speed: float = 0.0
var distance_traveled: float = 0.0
var score_per_distance: float = 0.1  # 1 point every 10 units

# Path for saving high score
const SAVE_FILE_PATH = "user://highscore.save"

# Node references
@onready var player: Player = $Player
@onready var obstacle_spawner: ObstacleManager = $ObstacleManager
@onready var score_label: Label = $UI/ScoreLabel
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var controls: ControlsManager = $Controls
@onready var world: Node2D = $World
@onready var parallax_background: ParallaxBackground = $ParallaxBackground

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
	
	# Setup input mappings
	_setup_input_actions()
	
	# Update UI
	update_score_display()
	update_high_score_display()
	
	# Automatically start after a short delay
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

func _process(delta: float) -> void:
	if not game_active:
		return
	
	# Increase speed over time
	current_speed = min(current_speed + speed_increase_per_second * delta, max_speed)
	
	# Move world and obstacles
	distance_traveled += current_speed * delta
	
	# Update score based on distance
	var new_score = int(distance_traveled * score_per_distance)
	if new_score > current_score:
		current_score = new_score
		update_score_display()
	
	# Move parallax background
	parallax_background.scroll_offset.x -= current_speed * delta

func start_game() -> void:
	# Reset game state
	current_score = 0
	distance_traveled = 0
	current_speed = starting_speed
	game_active = true
	
	# Reset player position
	player.global_position = Vector2(160, 700)
	player.reset()
	
	# Start obstacle spawning
	obstacle_spawner.set_spawn_speed(current_speed)
	obstacle_spawner.start()
	
	# Update UI
	update_score_display()
	
	# Show countdown
	_show_countdown()

func _show_countdown() -> void:
	countdown_label.visible = true
	countdown_label.text = "3"
	
	await get_tree().create_timer(0.5).timeout
	countdown_label.text = "2"
	
	await get_tree().create_timer(0.5).timeout
	countdown_label.text = "1"
	
	await get_tree().create_timer(0.5).timeout
	countdown_label.text = "GO!"
	
	await get_tree().create_timer(0.5).timeout
	countdown_label.visible = false

func _on_player_hit() -> void:
	# Player was hit by obstacle - game over
	game_active = false
	obstacle_spawner.stop()
	
	# Check for high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
		update_high_score_display()
	
	# Emit game over signal
	emit_signal("game_over", current_score)
	
	# Short delay before showing game over screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

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

# Control signal handlers
func _on_move_left_pressed() -> void:
	player.move_left()

func _on_move_left_released() -> void:
	player.stop_horizontal()

func _on_move_right_pressed() -> void:
	player.move_right()

func _on_move_right_released() -> void:
	player.stop_horizontal()

func _on_jump_pressed() -> void:
	player.try_jump()
