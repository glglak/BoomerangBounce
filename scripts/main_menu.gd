extends Control

# References to UI elements
@onready var play_button: Button = $PlayButton
@onready var quit_button: Button = $QuitButton
@onready var high_score_label: Label = $HighScoreLabel

# Save file path
const SAVE_FILE_PATH = "user://highscore.save"

func _ready() -> void:
	# Connect button signals
	play_button.connect("pressed", _on_play_button_pressed)
	quit_button.connect("pressed", _on_quit_button_pressed)
	
	# Display high score
	load_and_display_high_score()

func _on_play_button_pressed() -> void:
	# Start the game
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit_button_pressed() -> void:
	# Quit the game
	get_tree().quit()

func load_and_display_high_score() -> void:
	var high_score = 0
	
	# Try to load high score from file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score
	
	# Update the high score display
	high_score_label.text = "High Score: %d" % high_score
