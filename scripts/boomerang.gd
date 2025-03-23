extends Area2D
class_name Boomerang

signal completed_loop

# Boomerang movement properties
@export var flight_speed: float = 500.0
@export var rotation_speed: float = 10.0  # Rotations per second
@export var acceleration_factor: float = 1.05  # How much faster each round gets

# Path properties
@export var path_height: float = 400.0  # Maximum height of the arc
@export var path_width: float = 800.0   # Width of the arc path

# Internal state variables
var initial_position: Vector2
var target_position: Vector2
var t: float = 0.0  # Parameter to travel along path (0 to 1)
var is_returning: bool = false
var is_active: bool = false
var current_speed_multiplier: float = 1.0

# References
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Connect the body_entered signal
	connect("body_entered", _on_body_entered)
	
	# Initialize starting position
	initial_position = global_position
	
	# Initially deactivate the boomerang
	is_active = false
	visible = false
	
	# Make sure collision is enabled
	monitoring = true
	monitorable = true

func _physics_process(delta: float) -> void:
	if not is_active:
		return
		
	# Rotate the boomerang
	sprite.rotation += rotation_speed * delta * 2 * PI
	
	# Move along the arc path
	t += delta * flight_speed * current_speed_multiplier / path_width
	
	if not is_returning and t >= 0.5:
		# Reached the furthest point, start returning
		is_returning = true
	elif is_returning and t >= 1.0:
		# Completed the full loop
		reset()
		emit_signal("completed_loop")
	
	# Update position based on bezier curve or parabola
	global_position = calculate_position(t)

func throw(start_pos: Vector2, speed_multiplier: float = 1.0) -> void:
	# Set up and start the boomerang flight
	initial_position = start_pos
	global_position = initial_position
	t = 0.0
	is_returning = false
	is_active = true
	visible = true
	current_speed_multiplier = speed_multiplier

func reset() -> void:
	# Reset boomerang state
	is_active = false
	visible = false
	t = 0.0
	is_returning = false

func calculate_position(param: float) -> Vector2:
	# Simple parabolic/arc path calculation
	var x = initial_position.x + path_width * param
	
	# Parabolic height (highest at t=0.5)
	var height_factor = 1.0 - abs(param - 0.5) * 2.0  # 0->1->0 as t goes 0->0.5->1
	var y = initial_position.y - path_height * height_factor
	
	return Vector2(x, y)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		# Player hit by boomerang
		body.hit()
		# No need to deactivate here as the game will reset
