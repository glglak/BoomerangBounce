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

func _ready() -> void:
	# Connect button signals
	retry_button.connect("pressed", _on_retry_button_pressed)
	menu_button.connect("pressed", _on_menu_button_pressed)
	
	# Load high score
	load_high_score()
	
	# Update the UI
	update_score_display()

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
	# Go back to the game scene and restart
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu_button_pressed() -> void:
	# Go back to the main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

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
