extends StaticBody2D
class_name Platform

@export var move_speed: float = 0.0
@export var move_distance: float = 0.0
@export var move_direction: Vector2 = Vector2.ZERO
@export var is_moving: bool = false

var initial_position: Vector2
var target_position: Vector2
var move_progress: float = 0.0
var moving_forward: bool = true

func _ready() -> void:
	initial_position = position
	
	if is_moving and move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()
		target_position = initial_position + move_direction * move_distance

func _process(delta: float) -> void:
	if not is_moving or move_speed <= 0:
		return
	
	# Calculate movement based on ping-pong pattern
	if moving_forward:
		move_progress += move_speed * delta / move_distance
		if move_progress >= 1.0:
			move_progress = 1.0
			moving_forward = false
	else:
		move_progress -= move_speed * delta / move_distance
		if move_progress <= 0.0:
			move_progress = 0.0
			moving_forward = true
	
	# Update position
	position = initial_position.lerp(target_position, move_progress)
