extends Area2D
class_name Obstacle

@export var rotation_speed = 3.0  # Rotation speed for spinning effect
var speed = 300.0  # Movement speed (set by obstacle manager)

func _ready():
	# Connect the signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Rotate the obstacle
	rotate(rotation_speed * delta)

func set_speed(new_speed):
	speed = new_speed

func _on_body_entered(body):
	if body is Player:
		var player = body as Player
		player.hit()
