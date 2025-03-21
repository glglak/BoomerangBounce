extends Control
class_name MainMenu

# References to UI elements
@onready var title_label: Label = $TitleLabel
@onready var play_button: Button = $PlayButton
@onready var high_score_label: Label = $HighScoreLabel

# Path for high score file
const SAVE_FILE_PATH = "user://highscore.save"

func _ready() -> void:
	# Connect button signals
	play_button.connect("pressed", _on_play_button_pressed)
	
	# Load and display high score
	load_high_score()

func _on_play_button_pressed() -> void:
	# Transition to game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func load_high_score() -> void:
	var high_score = 0
	
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data and save_data.has("high_score"):
				high_score = save_data.high_score
	
	high_score_label.text = "High Score: %d" % high_score
