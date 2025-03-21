extends Area2D
class_name Obstacle

# Movement speed (set by obstacle manager)
var speed: float = 300.0

# Rotation speed for spin effect
@export var rotation_speed: float = 2.0

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the area entered signal
	body_entered.connect(_on_body_entered)

# Handle physics movement and behavior
func _physics_process(delta: float) -> void:
	# Rotate the obstacle
	rotate(rotation_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player
	if body is Player:
		var player = body as Player
		player.hit()
