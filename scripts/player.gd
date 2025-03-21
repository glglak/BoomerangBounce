extends CharacterBody2D
class_name Player

signal player_hit

# Movement lanes
@export var lane_width: float = 160.0
@export var num_lanes: int = 3
@export var lane_change_speed: float = 10.0  # Higher = faster lane change

# Jump properties
@export var jump_force: float = -600.0
@export var gravity: float = 1800.0
@export var max_fall_speed: float = 1200.0

# Double jump properties
@export var can_double_jump: bool = true
@export var double_jump_force: float = -500.0

# References to nodes
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# State variables
var current_lane: int = 1  # 0 = left, 1 = center, 2 = right
var target_x_position: float = 0.0
var is_jumping: bool = false
var has_double_jumped: bool = false
var is_dead: bool = false

func _ready() -> void:
	# Set initial position based on lane
	target_x_position = calculate_lane_position(current_lane)
	global_position.x = target_x_position

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		# Reset jumping states when landing
		is_jumping = false
		has_double_jumped = false
	
	# Handle lane movement (horizontal position)
	var lane_difference = target_x_position - global_position.x
	if abs(lane_difference) > 1.0:
		velocity.x = lane_difference * lane_change_speed
	else:
		velocity.x = 0
		global_position.x = target_x_position
	
	# Apply movement
	move_and_slide()
	
	# Update animation based on state
	_update_animation()

func _input(event: InputEvent) -> void:
	# Handle keyboard input (for testing)
	if event.is_action_pressed("move_left"):
		change_lane(-1)
	elif event.is_action_pressed("move_right"):
		change_lane(1)
	elif event.is_action_pressed("jump"):
		try_jump()

# Change lane by a relative amount (-1 for left, +1 for right)
func change_lane(direction: int) -> void:
	var new_lane = clamp(current_lane + direction, 0, num_lanes - 1)
	if new_lane != current_lane:
		current_lane = new_lane
		target_x_position = calculate_lane_position(current_lane)

# Calculate x position based on lane number
func calculate_lane_position(lane: int) -> float:
	var center_lane = num_lanes / 2.0
	return lane_width * (lane - center_lane + 0.5)

# Called from UI buttons
func move_left() -> void:
	change_lane(-1)

func move_right() -> void:
	change_lane(1)

func stop_horizontal() -> void:
	# Not needed in lane-based movement, but kept for API compatibility
	pass

func try_jump() -> void:
	if is_on_floor():
		jump()
	elif can_double_jump and is_jumping and not has_double_jumped:
		double_jump()

func jump() -> void:
	velocity.y = jump_force
	is_jumping = true
	
	# Play jump animation
	if animation_player.has_animation("jump"):
		animation_player.play("jump")

func double_jump() -> void:
	velocity.y = double_jump_force
	has_double_jumped = true
	
	# Play double jump animation
	if animation_player.has_animation("double_jump"):
		animation_player.play("double_jump")
	else:
		# Fallback to regular jump animation
		animation_player.play("jump")

func hit() -> void:
	if is_dead:
		return
		
	is_dead = true
	
	# Change appearance to show hit state
	sprite.modulate = Color(1, 0.5, 0.5, 0.8)  # Reddish tint
	
	# Play hit animation if available
	if animation_player.has_animation("hit"):
		animation_player.play("hit")
		
	# Emit signal for game manager to handle
	emit_signal("player_hit")

func reset() -> void:
	is_dead = false
	is_jumping = false
	has_double_jumped = false
	current_lane = 1
	target_x_position = calculate_lane_position(current_lane)
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE  # Reset color
	
	# Reset animation
	if animation_player.has_animation("idle"):
		animation_player.play("idle")

func _update_animation() -> void:
	if is_dead:
		return
		
	# Update player animation based on current state
	if is_jumping or not is_on_floor():
		if velocity.y < 0:
			if has_double_jumped and animation_player.has_animation("double_jump"):
				if not animation_player.is_playing() or animation_player.current_animation != "double_jump":
					animation_player.play("double_jump")
			else:
				if not animation_player.is_playing() or animation_player.current_animation != "jump":
					animation_player.play("jump")
		else:
			if animation_player.has_animation("fall"):
				if not animation_player.is_playing() or animation_player.current_animation != "fall":
					animation_player.play("fall")
			else:
				if not animation_player.is_playing() or animation_player.current_animation != "jump":
					animation_player.play("jump")
	else:
		if abs(velocity.x) > 10 and animation_player.has_animation("run"):
			if not animation_player.is_playing() or animation_player.current_animation != "run":
				animation_player.play("run")
		else:
			if not animation_player.is_playing() or animation_player.current_animation != "idle":
				animation_player.play("idle")
