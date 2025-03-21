extends CharacterBody2D
class_name Player

signal player_hit

# Player movement properties
@export var movement_speed: float = 300.0
@export var jump_force: float = -600.0
@export var gravity: float = 1500.0
@export var max_fall_speed: float = 1000.0
@export var acceleration: float = 3000.0
@export var friction: float = 1000.0
@export var air_resistance: float = 500.0

# Double jump properties
@export var can_double_jump: bool = true
@export var double_jump_force: float = -500.0

# References to other nodes (assigned in _ready)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# Movement state variables
var is_jumping: bool = false
var has_double_jumped: bool = false
var facing_right: bool = true
var move_direction: float = 0.0

func _ready() -> void:
	# Initialize animations, collision shape, etc.
	pass

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		# Reset jumping state when player lands
		is_jumping = false
		has_double_jumped = false
	
	# Get movement input (horizontal)
	move_direction = Input.get_axis("move_left", "move_right")
	
	# Apply horizontal movement with acceleration and friction
	if move_direction != 0:
		# Accelerate in the input direction
		velocity.x = move_toward(velocity.x, movement_speed * move_direction, acceleration * delta)
		
		# Update facing direction
		if move_direction > 0:
			facing_right = true
			sprite.scale.x = abs(sprite.scale.x)
		else:
			facing_right = false
			sprite.scale.x = -abs(sprite.scale.x)
	else:
		# Apply friction when no input
		var friction_to_apply = friction if is_on_floor() else air_resistance
		velocity.x = move_toward(velocity.x, 0, friction_to_apply * delta)
	
	# Apply movement
	move_and_slide()
	
	# Update animation
	_update_animation()

func _input(event: InputEvent) -> void:
	# Handle jump input
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump()
		elif can_double_jump and not has_double_jumped:
			double_jump()

# Called from UI buttons
func move_left() -> void:
	move_direction = -1.0

func move_right() -> void:
	move_direction = 1.0

func stop_moving() -> void:
	move_direction = 0.0

func try_jump() -> void:
	if is_on_floor():
		jump()
	elif can_double_jump and not has_double_jumped:
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
	
	# Play double jump animation if available
	if animation_player.has_animation("double_jump"):
		animation_player.play("double_jump")
	else:
		# Fallback to regular jump animation
		animation_player.play("jump")

func hit() -> void:
	# Player was hit by obstacle
	emit_signal("player_hit")
	
	# You can add effects here, like changing sprite color briefly
	# or playing a hit animation
	
func _update_animation() -> void:
	# Update player animation based on current state
	if is_jumping or not is_on_floor():
		if velocity.y < 0:
			if has_double_jumped and animation_player.has_animation("double_jump"):
				animation_player.play("double_jump")
			else:
				animation_player.play("jump")
		else:
			if animation_player.has_animation("fall"):
				animation_player.play("fall")
			else:
				animation_player.play("jump")
	elif abs(velocity.x) > 10:
		if animation_player.has_animation("run"):
			animation_player.play("run")
		else:
			animation_player.play("idle")
	else:
		animation_player.play("idle")
