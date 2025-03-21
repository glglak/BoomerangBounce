extends CharacterBody2D
class_name Player

signal player_hit

# Player jump properties
@export var jump_force: float = -600.0
@export var gravity: float = 1500.0
@export var max_fall_speed: float = 1000.0

# References to other nodes (assigned in _ready)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# State variable to track if the player is currently jumping
var is_jumping: bool = false

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
		
	# Move player based on current velocity
	move_and_slide()
	
	# Handle animation states
	_update_animation()

func _input(event: InputEvent) -> void:
	# Handle jump input - both touch and mouse for testing
	if event.is_action_pressed("jump") and is_on_floor():
		jump()

func jump() -> void:
	velocity.y = jump_force
	is_jumping = true
	
	# Play jump animation/sound here if available
	# animation_player.play("jump")

func hit() -> void:
	# Player was hit by boomerang
	emit_signal("player_hit")
	
	# You can add effects here, like changing sprite color briefly
	# or playing a hit animation
	
func _update_animation() -> void:
	# Update player animation based on current state
	if is_jumping:
		animation_player.play("jump")
	elif is_on_floor():
		animation_player.play("idle")
	else:
		animation_player.play("fall")
