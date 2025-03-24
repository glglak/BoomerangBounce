extends CharacterBody2D
class_name Player

signal player_hit
signal jump_performed  # Signal for jump sound

# Movement parameters
var screen_width: float = 540.0  # Default value in case of early access
var screen_margin: float = 50.0  # Margin from screen edges
var move_speed: float = 350.0  # Reduced to prevent too fast movement
var target_x_position: float = 270.0  # Default to center
var jumping_to_position: bool = false  # Track if we're in a directional jump

# Jump properties
@export var jump_force: float = -1100.0  # Stronger initial jump
@export var gravity: float = 2500.0
@export var double_jump_force: float = -1300.0  # Much stronger double jump
@export var triple_jump_force: float = -1500.0  # Extremely strong triple jump

# Character swap properties
var character_states = {
    "normal": "res://assets/player.svg",  # Default character
    "hit": "res://assets/player_hit.svg"  # Character after being hit
}
var current_character_state = "normal"
var hit_texture_loaded = false

# State variables
var is_jumping = false
var has_double_jumped = false
var has_triple_jumped = false
var jump_count = 0
var is_dead = false
var floor_y_position: float = 830.0  # Default value
var is_mobile = false
var last_jump_time: float = 0.0  # Track the last time a jump was performed
var jump_cooldown: float = 0.2    # Required time between jumps (in seconds)

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
    # Check if we're on mobile
    is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
    
    # Wait a frame to ensure viewport size is correct
    await get_tree().process_frame
    
    # Force immediate position update
    _update_screen_metrics()
    
    # Set up collision detection more reliably - using scale instead of modifying radius directly
    if collision_shape:
        var scale_factor = 1.2 if is_mobile else 1.0
        collision_shape.scale = Vector2(scale_factor, scale_factor)
    
    # Make sure we're using the normal character
    set_character_state("normal")
    
    # Preload hit texture to avoid loading delay when hit
    preload_hit_texture()

func preload_hit_texture():
    # Preload the hit texture to avoid loading delay when needed
    if character_states.has("hit"):
        var texture_path = character_states["hit"]
        var texture = load(texture_path)
        if texture != null:
            hit_texture_loaded = true
            print("Hit texture preloaded successfully")
        else:
            print("WARNING: Could not preload hit texture: " + texture_path)
            print("Creating default hit texture")
            # If the texture doesn't exist, use the normal texture with a red tint for hit state
            character_states["hit"] = character_states["normal"]

func _update_screen_metrics():
    # Get screen dimensions
    var viewport_rect = get_viewport_rect().size
    screen_width = viewport_rect.x
    
    # Set floor position based on platform - use a bigger offset on mobile for controls
    var floor_offset = 30
    if is_mobile:
        # On mobile, position higher to avoid controls at bottom
        floor_offset = 120  # Higher offset to stay above control panel
    
    # Calculate floor position to be above the bottom of the screen
    floor_y_position = viewport_rect.y - floor_offset
    
    # Start in the middle of the screen
    target_x_position = screen_width / 2
    global_position.x = target_x_position
    global_position.y = floor_y_position - 20  # Start slightly above floor to prevent collision issues
    
    # Log screen metrics for debugging
    print("Screen size: ", viewport_rect, " Floor Y: ", floor_y_position, " Player position: ", global_position)
    
    # Set initial animation
    animation_player.play("idle")

func _physics_process(delta):
    if is_dead:
        return
    
    # First, check if the screen dimensions have changed
    var current_viewport_rect = get_viewport_rect().size
    var expected_floor_offset = 120 if is_mobile else 30
    if abs(current_viewport_rect.x - screen_width) > 10 or abs(current_viewport_rect.y - floor_y_position - expected_floor_offset) > 10:
        _update_screen_metrics()
    
    # Apply gravity
    if not is_on_floor() and global_position.y < floor_y_position:
        velocity.y += gravity * delta
        velocity.y = min(velocity.y, 1500.0)  # Cap fall speed
    else:
        # Ensure player stays on floor
        if global_position.y >= floor_y_position:
            global_position.y = floor_y_position - 10
            velocity.y = 0
            
        # Reset jump states when on floor
        is_jumping = false
        has_double_jumped = false
        has_triple_jumped = false
        jump_count = 0
        jumping_to_position = false  # Reset position jump flag
    
    # Handle horizontal movement
    var x_diff = target_x_position - global_position.x
    if abs(x_diff) > 5.0 and (jumping_to_position or is_jumping):
        # Apply horizontal velocity for directional jumps or when moving while jumping
        velocity.x = sign(x_diff) * move_speed
    elif abs(x_diff) > 5.0 and !is_jumping:
        # When on ground, move more slowly to destination
        velocity.x = sign(x_diff) * (move_speed * 0.7)
    else:
        # Arrived at destination
        velocity.x = 0
        global_position.x = target_x_position
        
    # Apply movement
    move_and_slide()
    
    # Clamp position to stay in game area
    global_position.x = clamp(global_position.x, screen_margin, screen_width - screen_margin)
    
    # Ensure player doesn't go below floor
    global_position.y = min(global_position.y, floor_y_position)
    
    # Update animation based on state
    update_animation()

func _input(event):
    if is_dead:
        return
        
    # Handle keyboard input (for testing)
    if event.is_action_pressed("jump"):
        try_jump()
    
    # Handle touch input for directional jumping
    if event is InputEventScreenTouch and event.pressed:
        # Only process touch events if they're not on UI controls
        var viewport_size = get_viewport_rect().size
        if event.position.y < viewport_size.y - 150:  # Above the control area
            # Determine if tap is on left or right side of the screen
            if event.position.x < screen_width / 2:
                # Left side tap - jump left
                target_x_position = max(global_position.x - 170, screen_margin)
            else:
                # Right side tap - jump right
                target_x_position = min(global_position.x + 170, screen_width - screen_margin)
            
            # Set flag to indicate directional jump
            jumping_to_position = true
            try_jump()

# Set the character state (normal or hit)
func set_character_state(state: String):
    if state in character_states and state != current_character_state:
        current_character_state = state
        
        # Load the sprite texture for the new state
        var texture_path = character_states[state]
        var texture = load(texture_path)
        
        # Update the sprite if texture was loaded successfully
        if texture != null:
            sprite.texture = texture
            print("Changed character state to: " + state)
            
            # Apply red tint for hit state if using the same texture
            if state == "hit" and not hit_texture_loaded:
                sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)  # Red tint
            else:
                sprite.modulate = Color.WHITE  # Normal color
        else:
            push_error("Failed to load texture: " + texture_path)
            
            # Fallback for hit state - use red tint
            if state == "hit":
                sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)  # Red tint

# Set target position directly (used for touch controls)
func set_target_position(pos_x: float):
    target_x_position = clamp(pos_x, screen_margin, screen_width - screen_margin)
    jumping_to_position = true  # Mark that we're jumping to a position

# Called from directional controls
func move_left():
    target_x_position = max(global_position.x - screen_width/4, screen_margin)

func move_right():
    target_x_position = min(global_position.x + screen_width/4, screen_width - screen_margin)

func try_jump():
    # Check jump cooldown - this helps prevent accidental double taps on mobile
    var current_time = Time.get_ticks_msec() / 1000.0
    var time_since_last_jump = current_time - last_jump_time
    
    # If cooldown hasn't elapsed and we're not on the floor, ignore the jump
    if time_since_last_jump < jump_cooldown and jump_count > 0:
        return false
    
    # Update last jump time
    last_jump_time = current_time
    
    # If on floor or haven't jumped yet, do first jump
    if is_on_floor() or global_position.y >= floor_y_position - 20 or !is_jumping:
        jump_count = 1
        velocity.y = jump_force
        is_jumping = true
        has_double_jumped = false
        has_triple_jumped = false
        animation_player.play("jump")
        emit_signal("jump_performed")  # Emit signal for sound
        return true
        
    # If already jumped once but not twice, do double jump
    elif jump_count == 1:
        jump_count = 2
        velocity.y = double_jump_force
        has_double_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")  # Emit signal for sound
        return true
        
    # If already double jumped, do triple jump
    elif jump_count == 2:
        jump_count = 3
        velocity.y = triple_jump_force
        has_triple_jumped = true
        animation_player.play("double_jump")  # Reuse the same animation
        emit_signal("jump_performed")  # Emit signal for sound
        return true
        
    # No more jumps available
    return false

func update_animation():
    if is_dead:
        return
        
    if global_position.y < floor_y_position - 20:
        if velocity.y < 0:
            # Rising - show jump animation
            if has_triple_jumped and not animation_player.current_animation == "double_jump":
                animation_player.play("double_jump")
            elif has_double_jumped and not animation_player.current_animation == "double_jump":
                animation_player.play("double_jump")
            elif not animation_player.current_animation == "jump":
                animation_player.play("jump")
        elif velocity.y > 0 and not animation_player.current_animation == "fall":
            # Falling
            animation_player.play("fall")
    else:
        # On ground
        if abs(velocity.x) > 10 and not animation_player.current_animation == "run":
            animation_player.play("run")
        elif abs(velocity.x) <= 10 and not animation_player.current_animation == "idle":
            animation_player.play("idle")

func hit():
    if is_dead:
        return
    
    print("Player hit! Changing character state to hit")
    
    # Change character to hit state
    set_character_state("hit")
    
    # Mark as dead and stop movement
    is_dead = true
    velocity = Vector2.ZERO
    
    # Signal that player was hit
    emit_signal("player_hit")

func reset():
    print("Resetting player to normal state")
    
    # Change back to normal character state
    set_character_state("normal")
    
    is_dead = false
    is_jumping = false
    has_double_jumped = false
    has_triple_jumped = false
    jump_count = 0
    jumping_to_position = false
    
    # Force position update
    _update_screen_metrics()
    
    target_x_position = screen_width / 2
    global_position = Vector2(target_x_position, floor_y_position - 20)
    velocity = Vector2.ZERO
    sprite.modulate = Color.WHITE  # Reset color
    animation_player.play("idle")
