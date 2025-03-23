extends Area2D
class_name Obstacle

signal obstacle_passed

@export var rotation_speed = 3.0  # Rotation speed for spinning effect
var speed = 300.0  # Movement speed (set by obstacle manager)
var has_passed_player = false
var player_x_position = 100  # Default player x position

func _ready():
	# Connect the signal
	body_entered.connect(_on_body_entered)
	
	# No scaling - use original size

func _physics_process(delta):
	# Rotate the obstacle
	rotate(rotation_speed * delta)
	
	# Check if this obstacle has passed the player
	if not has_passed_player and position.x < player_x_position - 50:
		has_passed_player = true
		emit_signal("obstacle_passed")

func set_speed(new_speed):
	speed = new_speed

func set_player_position(pos_x):
	player_x_position = pos_x

func _on_body_entered(body):
	# Check if the body is the player
	if body is Player:
		var player = body as Player
		player.hit()
