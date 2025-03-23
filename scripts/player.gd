extends CharacterBody2D
class_name Player

signal player_hit
signal jump_performed  # Signal for jump sound

# Movement parameters
var screen_width: float
var screen_margin: float = 50.0  # Margin from screen edges
var move_speed: float = 350.0  # Reduced to prevent too fast movement
var target_x_position: float
var jumping_to_position: bool = false  # Track if we're in a directional jump

# Jump properties
@export var jump_force: float = -800.0
@export var gravity: float = 2500.0
@export var double_jump_force: float = -700.0

# State variables
var is_jumping = false
var has_double_jumped = false
var is_dead = false
var floor_y_position: float

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	# Force immediate position update
	call_deferred("_update_screen_metrics")

func _update_screen_metrics():
	# Get screen dimensions
	var viewport_rect = get_viewport_rect().size
	screen_width = viewport_rect.x
	
	# Set floor position to absolute bottom of screen
	floor_y_position = viewport_rect.y - 50  # Just a small margin from bottom
	print("Screen size: ", viewport_rect, " Floor Y: ", floor_y_position)
	
	# Start in the middle of the screen
	target_x_position = screen_width / 2
	global_position.x = target_x_position
	global_position.y = floor_y_position - 30  # Start slightly above floor
	
	# Set initial animation
	animation_player.play("idle")
	
	# Scale the character
	scale = Vector2(1.5, 1.5)

func _physics_process(delta):
	if is_dead:
		return
	
	# First, check if the screen dimensions have changed
	var current_viewport_rect = get_viewport_rect().size
	if abs(current_viewport_rect.x - screen_width) > 10 or abs(current_viewport_rect.y - floor_y_position - 50) > 10:
		_update_screen_metrics()
	
	# Apply gravity
	if not is_on_floor() and global_position.y < floor_y_position:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 1500.0)  # Cap fall speed
	else:
		# Ensure player stays on floor
		if global_position.y >= floor_y_position:
			global_position.y = floor_y_position - 10
			velocity.y = 0
			
		# Reset jump states when on floor
		is_jumping = false
		has_double_jumped = false
		jumping_to_position = false  # Reset position jump flag
	
	# Handle horizontal movement
	var x_diff = target_x_position - global_position.x
	if abs(x_diff) > 5.0 and (jumping_to_position or is_jumping):
		# Apply horizontal velocity for directional jumps or when moving while jumping
		velocity.x = sign(x_diff) * move_speed
	elif abs(x_diff) > 5.0 and !is_jumping:
		# When on ground, move more slowly to destination
		velocity.x = sign(x_diff) * (move_speed * 0.7)
	else:
		# Arrived at destination
		velocity.x = 0
		global_position.x = target_x_position
		
	# Apply movement
	move_and_slide()
	
	# Clamp position to stay in game area
	global_position.x = clamp(global_position.x, screen_margin, screen_width - screen_margin)
	global_position.y = min(global_position.y, floor_y_position)
	
	# Update animation based on state
	update_animation()

func _input(event):
	if is_dead:
		return
		
	# Handle keyboard input (for testing)
	if event.is_action_pressed("jump"):
		try_jump()

# Set target position directly (used for touch controls)
func set_target_position(pos_x: float):
	target_x_position = clamp(pos_x, screen_margin, screen_width - screen_margin)
	jumping_to_position = true  # Mark that we're jumping to a position

# Called from directional controls
func move_left():
	target_x_position = max(global_position.x - screen_width/4, screen_margin)

func move_right():
	target_x_position = min(global_position.x + screen_width/4, screen_width - screen_margin)

func try_jump():
	if !is_jumping or is_on_floor() or global_position.y >= floor_y_position - 20:
		# First jump
		velocity.y = jump_force
		is_jumping = true
		animation_player.play("jump")
		emit_signal("jump_performed")  # Emit signal for sound
	elif is_jumping and not has_double_jumped:
		# Double jump
		velocity.y = double_jump_force
		has_double_jumped = true
		animation_player.play("double_jump")
		emit_signal("jump_performed")  # Emit signal for sound

func update_animation():
	if is_dead:
		return
		
	if global_position.y < floor_y_position - 20:
		if velocity.y < 0:
			# Rising - show jump animation
			if has_double_jumped and not animation_player.current_animation == "double_jump":
				animation_player.play("double_jump")
			elif not animation_player.current_animation == "jump":
				animation_player.play("jump")
		elif velocity.y > 0 and not animation_player.current_animation == "fall":
			# Falling
			animation_player.play("fall")
	else:
		# On ground
		if abs(velocity.x) > 10 and not animation_player.current_animation == "run":
			animation_player.play("run")
		elif abs(velocity.x) <= 10 and not animation_player.current_animation == "idle":
			animation_player.play("idle")

func hit():
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	sprite.modulate = Color(1, 0.5, 0.5, 0.8)  # Reddish tint
	emit_signal("player_hit")

func reset():
	is_dead = false
	is_jumping = false
	has_double_jumped = false
	jumping_to_position = false
	
	# Force position update
	_update_screen_metrics()
	
	target_x_position = screen_width / 2
	global_position = Vector2(target_x_position, floor_y_position - 30)
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE  # Reset color
	animation_player.play("idle")
