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
var is_mobile = false
var has_hit_player = false  # Track if we've already hit the player
var boomerang_texture = null

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	# Check if running on mobile
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Connect the body_entered signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("Connected boomerang body_entered signal")
	
	# Make boomerang larger for better visibility
	var scale_factor = 4.0  # INCREASED scale factor for much better visibility
	if is_mobile:
		scale_factor = 4.5  # INCREASED even more on mobile
	
	# Try to load the boomerang texture from multiple possible paths
	var possible_paths = [
		"res://assets/sprites/boomerang.svg",
		"res://assets/boomerang.svg",
		"res://static/boomerang.svg",
		"res://boomerang.svg"
	]
	
	for path in possible_paths:
		boomerang_texture = load(path)
		if boomerang_texture != null:
			sprite.texture = boomerang_texture
			print("Successfully loaded boomerang texture from: " + path)
			break
	
	if boomerang_texture == null:
		# Force a texture for the boomerang - create a simple colored rectangle
		print("WARNING: Failed to load boomerang texture. Creating a fallback shape.")
		var fallback_texture = ImageTexture.create_from_image(Image.create(50, 50, false, Image.FORMAT_RGBA8))
		# Draw a solid color on the texture
		var image = fallback_texture.get_image()
		image.fill(Color(1.0, 0.3, 0.3, 1.0))  # Bright red color for visibility
		sprite.texture = fallback_texture
	
	# Scale both the sprite and collision shape
	sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Ensure sprite color is set to solid (no transparency)
	sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)  # Bright red for visibility
	
	if collision_shape:
		collision_shape.scale = Vector2(scale_factor, scale_factor)
	
	# Initialize starting position
	initial_position = global_position
	
	# Initially deactivate the boomerang
	is_active = false
	visible = false
	monitoring = true
	monitorable = true
	has_hit_player = false
	
	print("Boomerang initialized with scale factor:", scale_factor)

func _physics_process(delta: float) -> void:
	if not is_active:
		return
		
	# Rotate the boomerang faster
	sprite.rotation += rotation_speed * delta * 2 * PI
	
	# Ensure visibility and color stays consistent
	visible = true
	sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)  # Keep it consistently red
	
	# Move along the arc path
	t += delta * flight_speed * current_speed_multiplier / path_width
	
	if not is_returning and t >= 0.5:
		# Reached the furthest point, start returning
		is_returning = true
	elif is_returning and t >= 1.0:
		# Completed the full loop
		reset()
		emit_signal("completed_loop")
		print("Boomerang completed loop - emitting signal")
	
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
	has_hit_player = false
	current_speed_multiplier = speed_multiplier
	
	# Ensure visibility and color stays consistent
	sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)  # Bright red for visibility
	print("Boomerang thrown from position: ", start_pos)

func reset() -> void:
	# Reset boomerang state
	is_active = false
	visible = false
	t = 0.0
	is_returning = false
	has_hit_player = false

func calculate_position(param: float) -> Vector2:
	# Simple parabolic/arc path calculation
	var x = initial_position.x + path_width * param
	
	# Parabolic height (highest at t=0.5)
	var height_factor = 1.0 - abs(param - 0.5) * 2.0  # 0->1->0 as t goes 0->0.5->1
	var y = initial_position.y - path_height * height_factor
	
	return Vector2(x, y)

func _on_body_entered(body: Node) -> void:
	if body is Player and not has_hit_player:
		# Player hit by boomerang - only hit once 
		has_hit_player = true
		
		# Give a brief visual indication
		sprite.modulate = Color(1.0, 0.1, 0.1, 1.0)  # Even brighter red tint on collision
		
		print("Boomerang hit player at position: " + str(global_position))
		print("Player position: " + str(body.global_position))
		
		body.hit()
		# No need to deactivate here as the game will reset
