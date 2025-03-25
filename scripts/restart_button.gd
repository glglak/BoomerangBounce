extends Button

var is_mobile = false
var button_pressed = false  # Prevent double-presses
var debounce_timer = null  # Timer for input protection

func _ready():
	# Check platform
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Ensure button is properly configured for input
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	flat = false  # Non-flat buttons are more visible on mobile
	focus_mode = Control.FOCUS_ALL  # Ensure button can be focused by input events
	
	# Make button more visible and touchable on mobile
	if is_mobile:
		custom_minimum_size = Vector2(180, 80)  # INCREASED size
		modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full opacity
	
	# Create a timer for debouncing
	debounce_timer = Timer.new()
	debounce_timer.one_shot = true
	debounce_timer.wait_time = 0.5
	debounce_timer.autostart = false
	add_child(debounce_timer)
	debounce_timer.timeout.connect(_on_debounce_timer_timeout)
	
	# Reset button state
	button_pressed = false
	
	# Check if signal is already connected to avoid duplicate connections
	if not pressed.is_connected(_on_button_pressed):
		pressed.connect(_on_button_pressed)
	
	print("Restart button initialized with IMPROVED mobile configuration")

func _input(event):
	# Additional input handling for touch devices
	if is_mobile and event is InputEventScreenTouch:
		if event.pressed and not button_pressed:
			# Check if touch is on this button's area
			if get_global_rect().has_point(event.position):
				print("Touch detected on restart button at " + str(event.position))
				_on_button_pressed()
				get_viewport().set_input_as_handled()
				return true  # Consume event

func _on_button_pressed():
	print("Restart button pressed")
	
	# Prevent double-presses
	if button_pressed or debounce_timer.time_left > 0:
		print("Input blocked - debounce timer active")
		return
	
	button_pressed = true
	debounce_timer.start()
	
	# Add visual feedback for button press
	modulate = Color(0.7, 0.7, 0.7)  # Darker button for feedback
	
	# IMPORTANT: Use a call_deferred to avoid potential deadlocks
	call_deferred("_perform_restart")

func _perform_restart():
	# Get reference to the game manager (parent node)
	var game_manager = get_node("/root/Game")
	if game_manager:
		# Call restart function on game manager
		game_manager.restart_game()
	else:
		push_error("Could not find Game node")
		print("Could not find Game node")
		button_pressed = false
		modulate = Color(1, 1, 1)  # Reset color

func _on_debounce_timer_timeout():
	button_pressed = false
	modulate = Color(1, 1, 1)  # Reset color
