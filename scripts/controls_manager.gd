extends CanvasLayer
class_name ControlsManager

# Signals to connect to player
signal move_left_pressed
signal move_left_released
signal move_right_pressed
signal move_right_released
signal jump_pressed
signal set_target_position(pos_x)  # New signal to set exact target position

# Touch state
var left_touch_idx: int = -1
var right_touch_idx: int = -1
var jump_touch_idx: int = -1
var directional_jump_touch_idx: Array = []  # Store indexes for directional jumps

# Button references
@onready var left_button: TextureButton = $LeftButton
@onready var right_button: TextureButton = $RightButton
@onready var jump_button: TextureButton = $JumpButton

func _ready() -> void:
	# Connect button signals
	left_button.connect("button_down", _on_left_button_down)
	left_button.connect("button_up", _on_left_button_up)
	
	right_button.connect("button_down", _on_right_button_down)
	right_button.connect("button_up", _on_right_button_up)
	
	jump_button.connect("button_down", _on_jump_button_down)

func _input(event: InputEvent) -> void:
	# Handle touch input
	if event is InputEventScreenTouch:
		_handle_touch_event(event)

func _handle_touch_event(event: InputEventScreenTouch) -> void:
	var touch_position = event.position
	
	# Check which control area was touched
	if event.pressed:
		# New touch started
		if _is_touch_in_left_control(touch_position):
			left_touch_idx = event.index
			emit_signal("move_left_pressed")
		elif _is_touch_in_right_control(touch_position):
			right_touch_idx = event.index
			emit_signal("move_right_pressed")
		elif _is_touch_in_jump_control(touch_position):
			jump_touch_idx = event.index
			emit_signal("jump_pressed")
		else:
			# For touches elsewhere on screen, jump toward that x position
			directional_jump_touch_idx.append(event.index)
			
			# Signal player to jump
			emit_signal("jump_pressed")
			
			# Signal player to move toward touch position
			emit_signal("set_target_position", touch_position.x)
			
			# Register input actions
			Input.action_press("jump")
			
			# Auto-release jump after short time
			await get_tree().create_timer(0.1).timeout
			Input.action_release("jump")
	else:
		# Touch ended
		if event.index == left_touch_idx:
			left_touch_idx = -1
			emit_signal("move_left_released")
		elif event.index == right_touch_idx:
			right_touch_idx = -1
			emit_signal("move_right_released")
		elif event.index == jump_touch_idx:
			jump_touch_idx = -1
		elif event.index in directional_jump_touch_idx:
			directional_jump_touch_idx.erase(event.index)

func _is_touch_in_left_control(pos: Vector2) -> bool:
	return left_button.get_global_rect().has_point(pos)

func _is_touch_in_right_control(pos: Vector2) -> bool:
	return right_button.get_global_rect().has_point(pos)

func _is_touch_in_jump_control(pos: Vector2) -> bool:
	return jump_button.get_global_rect().has_point(pos)

# Button signal handlers
func _on_left_button_down() -> void:
	emit_signal("move_left_pressed")
	
	# Also register input action for player script to pick up
	Input.action_press("move_left")

func _on_left_button_up() -> void:
	emit_signal("move_left_released")
	
	# Release input action
	Input.action_release("move_left")

func _on_right_button_down() -> void:
	emit_signal("move_right_pressed")
	
	# Also register input action for player script to pick up
	Input.action_press("move_right")

func _on_right_button_up() -> void:
	emit_signal("move_right_released")
	
	# Release input action
	Input.action_release("move_right")

func _on_jump_button_down() -> void:
	emit_signal("jump_pressed")
	
	# Also register input action for player script to pick up
	Input.action_press("jump")
	
	# Auto-release the jump input after a short time
	await get_tree().create_timer(0.1).timeout
	Input.action_release("jump")
