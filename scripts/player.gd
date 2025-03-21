extends CharacterBody2D
class_name Player

signal player_hit

# Lane management
var current_lane = 1  # 0 = left, 1 = middle, 2 = right
var lane_positions = [100, 270, 440]  # x positions for lanes
var lane_change_speed = 500.0

# Jump properties
@export var jump_force: float = -600.0
@export var gravity: float = 1800.0
@export var double_jump_force: float = -500.0

# State variables
var is_jumping = false
var has_double_jumped = false
var is_dead = false
var target_x_position = lane_positions[1]  # Start in middle lane
var floor_y_position = 800  # Y position of the floor/ground

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	global_position.x = lane_positions[1]  # Start in middle lane
	global_position.y = floor_y_position - 30  # Start slightly above floor to account for character height
	animation_player.play("idle")

func _physics_process(delta):
	if is_dead:
		return
		
	# Apply gravity
	if not is_on_floor() and global_position.y < floor_y_position:
		velocity.y += gravity * delta
	else:
		# Ensure player stays on floor
		if global_position.y >= floor_y_position:
			global_position.y = floor_y_position - 10
			velocity.y = 0
			
		# Reset jump states when on floor
		is_jumping = false
		has_double_jumped = false
	
	# Handle lane movement (x position)
	var lane_diff = target_x_position - global_position.x
	if abs(lane_diff) > 5.0:
		velocity.x = lane_diff * lane_change_speed * delta
	else:
		velocity.x = 0
		global_position.x = target_x_position
		
	# Apply movement
	move_and_slide()
	
	# Clamp position to stay in game area
	global_position.y = min(global_position.y, floor_y_position)
	
	# Update animation based on state
	update_animation()

func _input(event):
	if is_dead:
		return
		
	# Handle keyboard input
	if event.is_action_pressed("move_left"):
		move_left()
	elif event.is_action_pressed("move_right"):
		move_right()
	elif event.is_action_pressed("jump"):
		try_jump()

func move_left():
	if current_lane > 0:
		current_lane -= 1
		target_x_position = lane_positions[current_lane]

func move_right():
	if current_lane < 2:
		current_lane += 1
		target_x_position = lane_positions[current_lane]

func try_jump():
	if !is_jumping or is_on_floor() or global_position.y >= floor_y_position - 20:
		# First jump
		velocity.y = jump_force
		is_jumping = true
		animation_player.play("jump")
	elif is_jumping and not has_double_jumped:
		# Double jump
		velocity.y = double_jump_force
		has_double_jumped = true
		animation_player.play("double_jump")

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
	current_lane = 1
	target_x_position = lane_positions[current_lane]
	global_position = Vector2(lane_positions[current_lane], floor_y_position - 30)
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	animation_player.play("idle")
