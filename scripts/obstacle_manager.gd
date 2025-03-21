extends Node2D
class_name ObstacleManager

# Obstacle prefabs
@export var obstacle_scene: PackedScene
@export var ground_obstacle_scene: PackedScene
@export var air_obstacle_scene: PackedScene

# Obstacle settings
@export var spawn_x_position = 600.0  # Spawn just off-screen to the right
@export var min_spawn_interval = 1.0  # Minimum time between obstacles
@export var max_spawn_interval = 2.5  # Maximum time between obstacles
@export var obstacle_speed = 300.0    # Base speed obstacles move
@export var speed_increase_rate = 10.0  # How much speed increases over time

# Lane positions (should match player's lane positions)
var lane_positions = [100, 270, 440]

# Internal variables
var active_obstacles = []
var spawn_timer = 0.0
var current_speed = 0.0
var is_active = false
var game_time = 0.0

func _ready():
	randomize()  # Initialize random seed

func start():
	# Clear any existing obstacles
	for obstacle in active_obstacles:
		obstacle.queue_free()
	active_obstacles.clear()
	
	# Initialize variables
	is_active = true
	game_time = 0
	current_speed = obstacle_speed
	spawn_timer = randf_range(min_spawn_interval, max_spawn_interval)

func stop():
	is_active = false

func _process(delta):
	if not is_active:
		return
		
	# Update game time
	game_time += delta
	
	# Increase speed over time
	current_speed = min(current_speed + speed_increase_rate * delta, obstacle_speed * 2)
	
	# Update spawn timer
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_obstacle()
		spawn_timer = randf_range(min_spawn_interval, max_spawn_interval)
		
		# Decrease spawn interval over time (makes game harder)
		min_spawn_interval = max(0.5, min_spawn_interval - 0.01)
		max_spawn_interval = max(1.0, max_spawn_interval - 0.01)
	
	# Move and update obstacles
	var obstacles_to_remove = []
	for obstacle in active_obstacles:
		# Move obstacle leftward
		obstacle.position.x -= current_speed * delta
		
		# Check if obstacle is off-screen and should be removed
		if obstacle.position.x < -50:
			obstacles_to_remove.append(obstacle)
	
	# Remove obstacles that are no longer needed
	for obstacle in obstacles_to_remove:
		active_obstacles.erase(obstacle)
		obstacle.queue_free()

func spawn_obstacle():
	# Decide which type of obstacle to spawn
	var obstacle_type = randi() % 3  # 0 = ground, 1 = air, 2 = random lane
	var obstacle
	
	if obstacle_type == 0 and ground_obstacle_scene:
		obstacle = ground_obstacle_scene.instantiate()
	elif obstacle_type == 1 and air_obstacle_scene:
		obstacle = air_obstacle_scene.instantiate()
	elif obstacle_scene:
		obstacle = obstacle_scene.instantiate()
	else:
		return  # No valid obstacle scene to spawn
	
	add_child(obstacle)
	active_obstacles.append(obstacle)
	
	# Position obstacle based on type
	var lane = randi() % 3  # Pick a random lane (0, 1, or 2)
	obstacle.position.x = spawn_x_position
	
	if obstacle_type == 0:  # Ground obstacle
		obstacle.position.y = 800  # Ground level
		obstacle.position.x = spawn_x_position + lane_positions[lane]
	elif obstacle_type == 1:  # Air obstacle (requires jumping)
		obstacle.position.y = 720  # Air level (requires a jump)
		obstacle.position.x = spawn_x_position + lane_positions[lane]
	else:  # Random lane obstacle
		obstacle.position.y = 800  # Ground level
		obstacle.position.x = spawn_x_position + lane_positions[lane]
	
	# Pass speed to obstacle if it has the property
	if obstacle.has_method("set_speed"):
		obstacle.set_speed(current_speed)
