extends Control

# References to UI elements
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton
@onready var high_score_label = $HighScoreLabel

# Save file path - same as in game_manager.gd
const SAVE_FILE_PATH = "user://highscore.save"

func _ready():
	# Connect button signals
	play_button.connect("pressed", Callable(self, "_on_play_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))
	
	# Display high score
	load_and_display_high_score()

func _on_play_button_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()

func load_and_display_high_score():
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
	high_score_label.text = "High Score: " + str(high_score)
