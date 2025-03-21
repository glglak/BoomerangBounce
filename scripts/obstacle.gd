extends Area2D
class_name Obstacle

@export var rotation_speed: float = 2.0
@export var bobbing_height: float = 5.0
@export var bobbing_speed: float = 2.0

var initial_y: float = 0
var time_offset: float = 0

func _ready() -> void:
	# Connect collision signal
	connect("body_entered", _on_body_entered)
	
	# Store initial vertical position
	initial_y = position.y
	
	# Set random time offset for bobbing
	time_offset = randf() * 10.0  # Add some variety to obstacle movement

func _process(delta: float) -> void:
	# Rotate the obstacle
	rotate(rotation_speed * delta)
	
	# Add subtle bobbing motion
	var bobbing_offset = sin((Time.get_ticks_msec() / 1000.0 + time_offset) * bobbing_speed) * bobbing_height
	position.y = initial_y + bobbing_offset

func _on_body_entered(body: Node) -> void:
	if body is Player:
		# Call the hit method on the player
		body.hit()
