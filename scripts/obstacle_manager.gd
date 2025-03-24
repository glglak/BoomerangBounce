extends Node2D
class_name ObstacleManager

signal obstacle_passed

# Obstacle prefabs
@export var obstacle_scene: PackedScene
@export var ground_obstacle_scene: PackedScene
@export var air_obstacle_scene: PackedScene
@export var boomerang_scene: PackedScene  # Added boomerang scene reference

# Obstacle settings
@export var spawn_x_position = 600.0  # Spawn just off-screen to the right
@export var min_spawn_interval = 1.5  # Minimum time between obstacles
@export var max_spawn_interval = 3.0  # Maximum time between obstacles
@export var initial_obstacle_speed = 200.0    # Initial speed obstacles move
@export var max_obstacle_speed = 400.0  # Maximum obstacle speed
@export var speed_increase_rate = 5.0  # How much speed increases per second

# Lane positions (should match player's lane positions)
var lane_positions = [100, 270, 440]

# Floor position for obstacles
var floor_y_position: float = 830  # Default, will be updated dynamically
var is_mobile = false

# Internal variables
var active_obstacles = []
var spawn_timer = 0.0
var current_speed = 0.0
var is_active = false
var game_time = 0.0
var difficulty_factor = 0.0  # 0 to 1, increases over time
var player_reference = null
var screen_height = 960  # Default, will be updated
var boomerang_spawn_chance = 0.3  # 30% chance of spawning a boomerang

func _ready():
	randomize()  # Initialize random seed
	
	# Check if we're on mobile
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Wait a frame to ensure viewport size is correct
	await get_tree().process_frame
	update_screen_metrics()

func update_screen_metrics():
	# Get the current viewport size
	var viewport_rect = get_viewport_rect().size
	screen_height = viewport_rect.y
	
	# Set floor position to be above controls on mobile
	var floor_offset = 30
	if is_mobile:
		floor_offset = 120  # Higher offset on mobile to account for control panel
	
	# Set floor position based on screen height
	floor_y_position = screen_height - floor_offset

func set_player_reference(player):
	player_reference = player

func start():
	# Update screen metrics first
	update_screen_metrics()
	
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
		if obstacle.position.x < -100:  # Increased to ensure obstacles fully exit
			obstacles_to_remove.append(obstacle)
	
	# Remove obstacles that are no longer needed
	for obstacle in obstacles_to_remove:
		active_obstacles.erase(obstacle)
		obstacle.queue_free()

func spawn_obstacle():
	# Determine if we should spawn a boomerang (higher chance than before)
	var should_spawn_boomerang = randf() < boomerang_spawn_chance
	var lane = randi() % 3  # Pick a random lane (0, 1, or 2)
	var obstacle
	
	if should_spawn_boomerang and boomerang_scene:
		# Spawn a boomerang
		obstacle = boomerang_scene.instantiate()
		print("Spawning boomerang obstacle")
	else:
		# Decide which type of regular obstacle to spawn
		# 0 = regular obstacle, 1 = ground obstacle, 2 = air obstacle
		var obstacle_type = randi() % 3
		
		if obstacle_type == 0 and obstacle_scene:
			obstacle = obstacle_scene.instantiate()
			print("Spawning regular obstacle")
		elif obstacle_type == 1 and ground_obstacle_scene:
			obstacle = ground_obstacle_scene.instantiate()
			print("Spawning ground obstacle")
		elif obstacle_type == 2 and air_obstacle_scene:
			obstacle = air_obstacle_scene.instantiate()
			print("Spawning air obstacle")
		elif obstacle_scene:  # Fallback to regular obstacle if chosen type isn't available
			obstacle = obstacle_scene.instantiate()
			print("Fallback to regular obstacle")
		else:
			print("Failed to spawn obstacle - no valid scene available")
			return  # No valid obstacle scene to spawn
	
	add_child(obstacle)
	
	# Connect obstacle's passed signal to our signal
	if obstacle.has_signal("obstacle_passed"):
		obstacle.connect("obstacle_passed", _on_obstacle_passed)
	elif obstacle.has_signal("completed_loop") and obstacle is Boomerang:
		obstacle.connect("completed_loop", _on_obstacle_passed)
	
	# Inform obstacle of player's x position
	if player_reference and obstacle.has_method("set_player_position"):
		obstacle.set_player_position(player_reference.global_position.x)
	
	active_obstacles.append(obstacle)
	
	# Position obstacle based on type
	var screen_center_y = screen_height / 2
	
	if obstacle is Boomerang:
		# Special handling for boomerang - position in middle of screen
		obstacle.throw(Vector2(spawn_x_position, screen_center_y), 1.0 + difficulty_factor * 0.5)
	else:
		# Position obstacle in middle of screen vertically
		var obstacle_y = screen_center_y
		
		# Adjust based on obstacle type with some randomness to avoid all being at same height
		var height_variance = randi() % 100 - 50  # Random -50 to +50 pixels
		
		if obstacle.get_meta("type", "") == "ground":
			obstacle_y = screen_center_y + 80 + height_variance  # Lower
		elif obstacle.get_meta("type", "") == "air":
			obstacle_y = screen_center_y - 80 + height_variance  # Higher
		else:
			obstacle_y = screen_center_y + height_variance  # Middle with variance
		
		# Ensure the obstacle isn't too close to the top or bottom
		obstacle_y = clamp(obstacle_y, 100, floor_y_position - 50)
		
		# Set position
		obstacle.position.y = obstacle_y
		obstacle.position.x = spawn_x_position
		obstacle.position.x += lane_positions[lane] - 270  # Offset based on lane
	
	# As difficulty increases, sometimes spawn multiple obstacles at once
	if difficulty_factor > 0.3 and randf() < difficulty_factor * 0.4:
		# Spawn a second obstacle in a different lane
		var second_lane = (lane + 1 + randi() % 2) % 3  # Ensure different lane
		var second_obstacle_type = randi() % 3  # Don't spawn a second boomerang
		var second_obstacle
		
		if second_obstacle_type == 0 and obstacle_scene:
			second_obstacle = obstacle_scene.instantiate()
		elif second_obstacle_type == 1 and ground_obstacle_scene:
			second_obstacle = ground_obstacle_scene.instantiate()
		elif air_obstacle_scene:
			second_obstacle = air_obstacle_scene.instantiate()
			
		if second_obstacle:
			add_child(second_obstacle)
			
			if second_obstacle.has_signal("obstacle_passed"):
				second_obstacle.connect("obstacle_passed", _on_obstacle_passed)
			
			if player_reference and second_obstacle.has_method("set_player_position"):
				second_obstacle.set_player_position(player_reference.global_position.x)
				
			active_obstacles.append(second_obstacle)
			
			# Position second obstacle with different height
			var second_obstacle_y = screen_center_y
			var height_variance = randi() % 100 - 50
			
			if second_obstacle_type == 1:  # Ground-type obstacle
				second_obstacle_y = screen_center_y + 80 + height_variance
			elif second_obstacle_type == 2:  # Air-type obstacle
				second_obstacle_y = screen_center_y - 80 + height_variance
			else:
				second_obstacle_y = screen_center_y + height_variance
				
			second_obstacle_y = clamp(second_obstacle_y, 100, floor_y_position - 50)
			
			second_obstacle.position.y = second_obstacle_y
			second_obstacle.position.x = spawn_x_position
			second_obstacle.position.x += lane_positions[second_lane] - 270

func _on_obstacle_passed():
	print("Obstacle passed - emitting signal")
	emit_signal("obstacle_passed")
