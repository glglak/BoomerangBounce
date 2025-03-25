extends Node2D

@onready var particles = $CPUParticles2D if has_node("CPUParticles2D") else null

# Called when the node enters the scene tree for the first time
func _ready():
	# Just make sure we're not auto-emitting
	if particles:
		particles.emitting = false

# Simple function to play the effect - no complex property handling
func play_jump_effect():
	if particles:
		# Just toggle emission - the scale is set in the scene directly
		particles.emitting = true
