extends Node2D
class_name ObstacleManager

# Obstacle patterns and settings
@export var obstacle_scene: PackedScene
@export var min_obstacle_distance: float = 500.0
@export var max_obstacle_distance: float = 1000.0
@export var min_speed: float = 300.0
@export var max_speed: float = 600.0
@export var speed_increase_rate: float = 10.0  # Units per second

# Internal variables
var active_obstacles = []
var current_speed: float = 300.0
var screen_width: float
var obstacle_spawn_x: float
var last_obstacle_x: float = 0
var next_obstacle_distance: float = 0

# Game state
var score: int = 0
var game_active: bool = false

func _ready() -> void:
	# Get screen dimensions
	screen_width = get_viewport_rect().size.x
	obstacle_spawn_x = screen_width + 100  # Start off-screen
	
	randomize()  # Initialize random number generator

func _process(delta: float) -> void:
	if not game_active:
		return
	
	# Increase speed over time
	current_speed = min(current_speed + speed_increase_rate * delta, max_speed)
	
	# Check if we need to spawn a new obstacle
	if obstacle_spawn_x - last_obstacle_x >= next_obstacle_distance:
		spawn_obstacle()
	
	# Move and manage active obstacles
	var obstacles_to_remove = []
	
	for obstacle in active_obstacles:
		# Move obstacle to the left
		obstacle.position.x -= current_speed * delta
		
		# Check if obstacle is off-screen to the left
		if obstacle.position.x < -100:
			obstacles_to_remove.append(obstacle)
			score += 1
	
	# Remove obstacles that have passed
	for obstacle in obstacles_to_remove:
		active_obstacles.erase(obstacle)
		obstacle.queue_free()
	
	# Update score
	if obstacles_to_remove.size() > 0:
		emit_signal("score_updated", score)

func start() -> void:
	score = 0
	current_speed = min_speed
	game_active = true
	next_obstacle_distance = get_random_distance()
	last_obstacle_x = obstacle_spawn_x - next_obstacle_distance  # To spawn first obstacle immediately
	
	# Clear any existing obstacles
	for obstacle in active_obstacles:
		obstacle.queue_free()
	active_obstacles.clear()

func stop() -> void:
	game_active = false

func spawn_obstacle() -> void:
	# Create new obstacle instance
	var obstacle = obstacle_scene.instantiate()
	add_child(obstacle)
	
	# Position obstacle off-screen to the right
	obstacle.position.x = obstacle_spawn_x
	obstacle.position.y = get_random_y_position()
	
	# Add to active obstacles list
	active_obstacles.append(obstacle)
	
	# Update last obstacle position and generate next distance
	last_obstacle_x = obstacle_spawn_x
	next_obstacle_distance = get_random_distance()

func get_random_distance() -> float:
	return randf_range(min_obstacle_distance, max_obstacle_distance)

func get_random_y_position() -> float:
	# This will be based on your game's specific layout
	# For now, we'll assume a fixed ground height and obstacles on the ground
	return 800  # Example ground position
