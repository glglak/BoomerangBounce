extends Node2D
class_name ObstacleManager

# Obstacle prefabs
@export var obstacle_scenes: Array[PackedScene] = []
@export var ground_obstacle_scene: PackedScene
@export var air_obstacle_scene: PackedScene
@export var full_obstacle_scene: PackedScene

# Spawning parameters
@export var spawn_ahead_distance: float = 1200.0  # Distance ahead to spawn obstacles
@export var min_obstacle_spacing: float = 600.0   # Minimum distance between obstacles
@export var max_obstacle_spacing: float = 1200.0  # Maximum distance between obstacles
@export var lane_width: float = 160.0             # Width of each lane
@export var num_lanes: int = 3                    # Number of lanes

# Obstacle properties
@export var obstacle_lifetime: float = 10.0       # Seconds before automatically removing obstacles
@export var obstacle_move_speed: float = 300.0    # Initial speed of obstacles
@export var speed_increase_rate: float = 10.0     # How much to increase speed over time
@export var difficulty_ramp_time: float = 30.0    # Seconds until reaching maximum difficulty

# Internal variables
var active_obstacles: Array = []
var spawn_position: float = 0.0
var spawn_timer: float = 0.0
var next_spawn_distance: float = 0.0
var current_speed: float = 0.0
var is_active: bool = false
var game_time: float = 0.0

func _ready() -> void:
	# Initialize with default obstacle if none specified
	if obstacle_scenes.is_empty() and ground_obstacle_scene == null and air_obstacle_scene == null:
		printerr("Warning: No obstacle scenes assigned to ObstacleManager")

func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Increase game time and update difficulty
	game_time += delta
	var difficulty_progress = min(game_time / difficulty_ramp_time, 1.0)
	
	# Move and update obstacles
	var obstacles_to_remove = []
	for obstacle in active_obstacles:
		# Move obstacle leftward
		obstacle.position.x -= current_speed * delta
		
		# Check if obstacle is off-screen and should be removed
		if obstacle.position.x < -200:
			obstacles_to_remove.append(obstacle)
	
	# Remove obstacles that are no longer needed
	for obstacle in obstacles_to_remove:
		active_obstacles.erase(obstacle)
		obstacle.queue_free()
	
	# Check if it's time to spawn a new obstacle
	spawn_position -= current_speed * delta
	if spawn_position <= spawn_ahead_distance:
		spawn_obstacle()

func start() -> void:
	# Reset internal state
	is_active = true
	game_time = 0.0
	
	# Clear any existing obstacles
	for obstacle in active_obstacles:
		obstacle.queue_free()
	active_obstacles.clear()
	
	# Initialize spawn position
	spawn_position = spawn_ahead_distance + min_obstacle_spacing
	
	# Set initial speed
	current_speed = obstacle_move_speed

func stop() -> void:
	is_active = false

func set_spawn_speed(speed: float) -> void:
	current_speed = speed
	obstacle_move_speed = speed

func spawn_obstacle() -> void:
	if not is_active:
		return
	
	var obstacle_scene: PackedScene
	var obstacle_type = randi() % 3  # 0 = ground, 1 = air, 2 = full
	
	# Select obstacle by type
	if obstacle_type == 0 and ground_obstacle_scene:
		obstacle_scene = ground_obstacle_scene
	elif obstacle_type == 1 and air_obstacle_scene:
		obstacle_scene = air_obstacle_scene
	elif obstacle_type == 2 and full_obstacle_scene:
		obstacle_scene = full_obstacle_scene
	elif not obstacle_scenes.is_empty():
		# Fall back to random from array if specific scenes not set
		obstacle_scene = obstacle_scenes[randi() % obstacle_scenes.size()]
	else:
		# No obstacle scenes available
		return
	
	# Create the obstacle
	var obstacle = obstacle_scene.instantiate()
	add_child(obstacle)
	
	# Position based on type
	var lane_position = randi() % num_lanes
	var lane_x = (lane_position - (num_lanes-1)/2.0) * lane_width + (lane_width / 2)
	
	obstacle.position.x = spawn_ahead_distance
	
	if obstacle_type == 0:  # Ground obstacle
		obstacle.position.y = 850  # Ground level
	elif obstacle_type == 1:  # Air obstacle
		obstacle.position.y = 750  # Elevated to require jumping
	else:  # Full obstacle (requires specific lane)
		obstacle.position.y = 800
		obstacle.position.x = lane_x
	
	# Add to active obstacles
	active_obstacles.append(obstacle)
	
	# Calculate next spawn position
	var spacing = randf_range(min_obstacle_spacing, max_obstacle_spacing)
	spawn_position += spacing
	
	# Update difficulty based on game time
	var difficulty_progress = min(game_time / difficulty_ramp_time, 1.0)
	min_obstacle_spacing = lerp(600.0, 400.0, difficulty_progress)
	max_obstacle_spacing = lerp(1200.0, 800.0, difficulty_progress)
