extends Node2D
class_name ObstacleManager

signal obstacle_passed

# Obstacle prefabs
@export var obstacle_scene: PackedScene
@export var ground_obstacle_scene: PackedScene
@export var air_obstacle_scene: PackedScene

# Obstacle settings
@export var spawn_x_position = 600.0  # Spawn just off-screen to the right
@export var min_spawn_interval = 1.5  # Minimum time between obstacles
@export var max_spawn_interval = 3.0  # Maximum time between obstacles
@export var initial_obstacle_speed = 200.0    # Initial speed obstacles move
@export var max_obstacle_speed = 400.0  # Maximum obstacle speed
@export var speed_increase_rate = 5.0  # How much speed increases per second

# Lane positions (should match player's lane positions)
var lane_positions = [100, 270, 440]

# Internal variables
var active_obstacles = []
var spawn_timer = 0.0
var current_speed = 0.0
var is_active = false
var game_time = 0.0
var difficulty_factor = 0.0  # 0 to 1, increases over time
var player_reference = null

func _ready():
	randomize()  # Initialize random seed

func set_player_reference(player):
	player_reference = player

func start():
	# Clear any existing obstacles
	for obstacle in active_obstacles:
		obstacle.queue_free()
	active_obstacles.clear()
	
	# Initialize variables
	is_active = true
	game_time = 0
	current_speed = initial_obstacle_speed
	difficulty_factor = 0.0
	spawn_timer = randf_range(min_spawn_interval, max_spawn_interval)

func stop():
	is_active = false

func _process(delta):
	if not is_active:
		return
		
	# Update game time
	game_time += delta
	
	# Update difficulty factor (maxes out at 1.0 after 60 seconds)
	difficulty_factor = min(game_time / 60.0, 1.0)
	
	# Increase speed over time
	current_speed = initial_obstacle_speed + (max_obstacle_speed - initial_obstacle_speed) * difficulty_factor
	
	# Update spawn timer
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_obstacle()
		
		# Spawn interval decreases as difficulty increases
		var current_min_interval = lerp(min_spawn_interval, 0.7, difficulty_factor)
		var current_max_interval = lerp(max_spawn_interval, 1.5, difficulty_factor)
		spawn_timer = randf_range(current_min_interval, current_max_interval)
	
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
	
	# Connect obstacle's passed signal to our signal
	obstacle.connect("obstacle_passed", _on_obstacle_passed)
	
	# Inform obstacle of player's x position
	if player_reference:
		obstacle.set_player_position(player_reference.global_position.x)
	
	active_obstacles.append(obstacle)
	
	# Position obstacle based on type
	var lane = randi() % 3  # Pick a random lane (0, 1, or 2)
	
	if obstacle_type == 0:  # Ground obstacle
		obstacle.position.y = 790  # Ground level
		obstacle.position.x = spawn_x_position
		obstacle.position.x += lane_positions[lane] - 270  # Offset based on lane
	elif obstacle_type == 1:  # Air obstacle (requires jumping)
		obstacle.position.y = 730  # Air level (requires a jump)
		obstacle.position.x = spawn_x_position
		obstacle.position.x += lane_positions[lane] - 270  # Offset based on lane
	else:  # Random lane obstacle
		obstacle.position.y = 790  # Ground level
		obstacle.position.x = spawn_x_position
		obstacle.position.x += lane_positions[lane] - 270  # Offset based on lane
	
	# As difficulty increases, sometimes spawn multiple obstacles at once
	if difficulty_factor > 0.3 and randf() < difficulty_factor * 0.5:
		# Spawn a second obstacle in a different lane
		var second_lane = (lane + 1 + randi() % 2) % 3  # Ensure different lane
		var second_obstacle
		
		if randi() % 2 == 0 and ground_obstacle_scene:
			second_obstacle = ground_obstacle_scene.instantiate()
			second_obstacle.position.y = 790
		elif air_obstacle_scene:
			second_obstacle = air_obstacle_scene.instantiate()
			second_obstacle.position.y = 730
			
		if second_obstacle:
			add_child(second_obstacle)
			second_obstacle.connect("obstacle_passed", _on_obstacle_passed)
			
			if player_reference:
				second_obstacle.set_player_position(player_reference.global_position.x)
				
			active_obstacles.append(second_obstacle)
			second_obstacle.position.x = spawn_x_position
			second_obstacle.position.x += lane_positions[second_lane] - 270

func _on_obstacle_passed():
	emit_signal("obstacle_passed")
