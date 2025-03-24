extends Area2D
class_name Obstacle

signal obstacle_passed

@export var rotation_speed = 3.0  # Rotation speed for spinning effect
var speed = 300.0  # Movement speed (set by obstacle manager)
var has_passed_player = false
var has_passed_score_zone = false  # Track if we've already incremented score
var player_x_position = 100  # Default player x position
var is_mobile = false  # Will be set in _ready
var has_hit_player = false  # Prevent multiple collisions

func _ready():
	# Check if running on mobile
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Connect the signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("Connected body_entered signal")
	
	# Make obstacles bigger, especially on mobile
	var scale_factor = 1.5  # Make obstacles significantly larger
	if is_mobile:
		scale_factor = 1.7  # Even larger on mobile
	
	# Apply scaling to sprite
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
	
	# Scale the collision shape instead of modifying properties directly
	# This avoids errors with different shape types
	if has_node("CollisionShape2D"):
		$CollisionShape2D.scale = Vector2(scale_factor, scale_factor)
	
	# Ensure the sprite color is white (no tinting)
	$Sprite2D.modulate = Color.WHITE
	
	print("Obstacle initialized with scale factor: ", scale_factor)

func _physics_process(delta):
	# Rotate the obstacle
	rotate(rotation_speed * delta)
	
	# Ensure color stays consistent
	$Sprite2D.modulate = Color.WHITE
	
	# Check if this obstacle has passed the player and hasn't been counted yet
	if not has_passed_score_zone and position.x < player_x_position - 50:
		has_passed_score_zone = true  # Mark as counted
		emit_signal("obstacle_passed")
		print("Obstacle passing player - emitting passed signal")

func set_speed(new_speed):
	speed = new_speed

func set_player_position(pos_x):
	player_x_position = pos_x

func _on_body_entered(body: Node) -> void:
	if body is Player and not has_hit_player:
		# Mark as having hit player to prevent multiple hits
		has_hit_player = true
		
		# Give a brief visual indication
		$Sprite2D.modulate = Color(1.0, 0.5, 0.5)  # Red tint on collision
		
		print("Obstacle hit player at position: " + str(global_position))
		print("Player position: " + str(body.global_position))
		
		# Player hit by obstacle - only count once
		body.hit()
