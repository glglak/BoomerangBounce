extends Control
class_name GameOverScreen

# References to UI elements
@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton

# Score data
var final_score: int = 0
var high_score: int = 0
var is_mobile = false
var button_pressed = false  # Flag to prevent double presses
var debounce_timer = null   # Timer for preventing multiple clicks

func _ready() -> void:
	# Check platform
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	print("Game over screen initializing on", "mobile" if is_mobile else "desktop")
	
	# Create debounce timer
	debounce_timer = Timer.new()
	debounce_timer.one_shot = true
	debounce_timer.wait_time = 0.5
	debounce_timer.autostart = false
	add_child(debounce_timer)
	debounce_timer.timeout.connect(_on_debounce_timer_timeout)
	
	# Make buttons more touch-friendly on mobile
	if is_mobile:
		if retry_button:
			retry_button.custom_minimum_size = Vector2(250, 100)  # INCREASED SIZE
			retry_button.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full opacity
		if menu_button:
			menu_button.custom_minimum_size = Vector2(250, 100)  # INCREASED SIZE
			menu_button.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full opacity
	
	# Set button input processing for better touch response
	if retry_button:
		retry_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		retry_button.mouse_filter = Control.MOUSE_FILTER_STOP
		retry_button.focus_mode = Control.FOCUS_ALL
	
	if menu_button:
		menu_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		menu_button.focus_mode = Control.FOCUS_ALL
	
	# Connect button signals using direct approach
	if retry_button:
		# Disconnect any existing connections to prevent duplicates
		if retry_button.pressed.is_connected(_on_retry_button_pressed):
			retry_button.pressed.disconnect(_on_retry_button_pressed)
		
		# Add new connection and make button GUI-navigable
		retry_button.pressed.connect(_on_retry_button_pressed)
		retry_button.focus_mode = Control.FOCUS_ALL
		
		# Set button texture for better visibility on mobile
		retry_button.flat = false
	
	if menu_button:
		# Disconnect any existing connections to prevent duplicates
		if menu_button.pressed.is_connected(_on_menu_button_pressed):
			menu_button.pressed.disconnect(_on_menu_button_pressed)
		
		# Add new connection and make button GUI-navigable
		menu_button.pressed.connect(_on_menu_button_pressed)
		menu_button.focus_mode = Control.FOCUS_ALL
		
		# Set button texture for better visibility on mobile
		menu_button.flat = false
	
	# Load high score
	load_high_score()
	
	# Update the UI
	update_score_display()
	
	# Reset button pressed flag
	button_pressed = false
	
	print("Game over screen initialized with buttons connected")

func _input(event):
	# Additional input handling for touch devices
	if is_mobile and event is InputEventScreenTouch:
		if event.pressed and not button_pressed and debounce_timer.time_left <= 0:
			# Check if touch is on retry button
			if retry_button and retry_button.get_global_rect().has_point(event.position):
				print("Touch detected on retry button at " + str(event.position))
				_on_retry_button_pressed()
				get_viewport().set_input_as_handled()
				return true
			
			# Check if touch is on menu button
			elif menu_button and menu_button.get_global_rect().has_point(event.position):
				print("Touch detected on menu button at " + str(event.position))
				_on_menu_button_pressed()
				get_viewport().set_input_as_handled()
				return true

func set_score(score: int) -> void:
	final_score = score
	
	# Check for new high score
	if final_score > high_score:
		high_score = final_score
		save_high_score()
	
	# Update the UI
	update_score_display()

func update_score_display() -> void:
	score_label.text = "Score: %d" % final_score
	high_score_label.text = "High Score: %d" % high_score
	
	# Highlight if it's a new high score
	if final_score >= high_score:
		high_score_label.add_theme_color_override("font_color", Color(1, 0.8, 0))

func _on_retry_button_pressed() -> void:
	print("Retry button pressed")
	
	# Prevent double-presses
	if button_pressed or debounce_timer.time_left > 0:
		print("Input blocked - debounce timer active")
		return
	
	button_pressed = true
	debounce_timer.start()
	
	# Add visual feedback for mobile
	if retry_button:
		retry_button.modulate = Color(0.7, 0.7, 0.7)  # Darker for better feedback
	
	# Use call_deferred for safety
	call_deferred("_change_to_game")

func _change_to_game() -> void:
	# Go back to the game scene and restart
	print("Changing to game scene...")
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu_button_pressed() -> void:
	print("Menu button pressed")
	
	# Prevent double-presses
	if button_pressed or debounce_timer.time_left > 0:
		print("Input blocked - debounce timer active")
		return
	
	button_pressed = true
	debounce_timer.start()
	
	# Add visual feedback for mobile
	if menu_button:
		menu_button.modulate = Color(0.7, 0.7, 0.7)  # Darker for better feedback
	
	# Use call_deferred for safety
	call_deferred("_change_to_menu")

func _change_to_menu() -> void:
	# Go back to the main menu
	print("Changing to main menu scene...")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_debounce_timer_timeout() -> void:
	button_pressed = false
	if retry_button:
		retry_button.modulate = Color(1, 1, 1)  # Reset color
	if menu_button:
		menu_button.modulate = Color(1, 1, 1)  # Reset color

func load_high_score() -> void:
	const SAVE_FILE_PATH = "user://highscore.save"
	
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score

func save_high_score() -> void:
	const SAVE_FILE_PATH = "user://highscore.save"
	
	var save_data = {
		"high_score": high_score
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
