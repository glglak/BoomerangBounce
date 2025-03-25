extends Node2D

@onready var particles = $CPUParticles2D if has_node("CPUParticles2D") else null

# Called when the node enters the scene tree for the first time
func _ready():
	if particles:
		# Fix for scale_amount property in Godot 4
		if particles.has_method("set_param_min") and particles.has_method("set_param_max"):
			# Use Godot 4's renamed methods
			particles.set_param_min(GPUParticles2D.PARAM_SCALE, 1.0)  # Default value, adjust as needed
			particles.set_param_max(GPUParticles2D.PARAM_SCALE, 1.0)  # Default value, adjust as needed
		elif particles.has_method("set_scale_amount"):
			# Use legacy method if available
			particles.set_scale_amount(1.0)  # Default value, adjust as needed
		else:
			# Fallback for newer Godot versions
			particles.scale_amount_min = 1.0  # Default value, adjust as needed
			particles.scale_amount_max = 1.0  # Default value, adjust as needed

# Call this method to play the jump effect
func play_jump_effect():
	if particles:
		particles.emitting = true
