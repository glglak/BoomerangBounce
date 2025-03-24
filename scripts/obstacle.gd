extends Area2D
class_name Obstacle

signal obstacle_passed

@export var rotation_speed = 3.0  # Rotation speed for spinning effect
var speed = 300.0  # Movement speed (set by obstacle manager)
var has_passed_player = false
var player_x_position = 100  # Default player x position
var is_mobile = false  # Will be set in _ready

func _ready():
	# Connect the signal
	body_entered.connect(_on_body_entered)
	
	# Detect if running on mobile
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Make obstacles bigger, especially on mobile
	var scale_factor = 1.25
	if is_mobile:
		scale_factor = 1.4  # Even larger on mobile
	
	# Apply scaling to sprite and collision
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
	
	# Make sure collision shape is appropriately sized
	if $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius *= scale_factor
	elif $CollisionShape2D.shape is RectangleShape2D:
		$CollisionShape2D.shape.size *= scale_factor
	
	# Ensure the sprite color is white (no tinting)
	$Sprite2D.modulate = Color.WHITE

func _physics_process(delta):
	# Rotate the obstacle
	rotate(rotation_speed * delta)
	
	# Ensure color stays consistent
	$Sprite2D.modulate = Color.WHITE
	
	# Check if this obstacle has passed the player
	if not has_passed_player and position.x < player_x_position - 50:
		has_passed_player = true
		emit_signal("obstacle_passed")

func set_speed(new_speed):
	speed = new_speed

func set_player_position(pos_x):
	player_x_position = pos_x

func _on_body_entered(body):
	# Check if the body is the player with improved collision detection
	if body is Player:
		var player = body as Player
		
		# Add a small delay before registering hit on mobile to prevent false hits
		if is_mobile:
			# Give a small grace period on mobile if player is jumping
			if player.is_jumping and player.velocity.y < 0:
				await get_tree().create_timer(0.05).timeout
				
				# If player has moved past the obstacle during grace period, don't count as hit
				if position.x < player.global_position.x - 40:
					return
		
		# Register the hit
		player.hit()
