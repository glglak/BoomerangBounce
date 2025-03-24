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

# Jump properties - SIGNIFICANTLY STRONGER FOR MOBILE
@export var jump_force: float = -1200.0
@export var gravity: float = 2500.0
@export var double_jump_force: float = -1400.0
@export var triple_jump_force: float = -1600.0

# Mobile-specific parameters
var mobile_jump_force_multiplier = 1.4  # Stronger jumps on mobile
var mobile_double_jump_force_multiplier = 1.5
var mobile_triple_jump_force_multiplier = 1.6
var mobile_move_speed_multiplier = 1.3  # Faster horizontal movement on mobile
var mobile_jump_horizontal_distance = 0.3  # As percentage of screen width

# Character swap properties
var character_states = {
    "normal": "res://assets/sprites/player.svg",  # Default character
    "hit": "res://assets/sprites/player_hit.svg"  # Character after being hit
}
var hit_texture = null
var normal_texture = null
var current_character_state = "normal"

# State variables
var is_jumping = false
var has_double_jumped = false
var has_triple_jumped = false
var jump_count = 0
var is_dead = false
var floor_y_position: float = 830.0  # Default value
var is_mobile = false
var last_jump_time: float = 0.0  # Track the last time a jump was performed
var jump_cooldown: float = 0.15  # Reduced cooldown for better response
var last_touch_position: Vector2 = Vector2.ZERO
var can_jump = true  # Flag to control jump availability

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
    # Check if we're on mobile
    is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
    
    # Preload textures
    preload_textures()
    
    # Wait a frame to ensure viewport size is correct
    await get_tree().process_frame
    
    # Force immediate position update
    _update_screen_metrics()
    
    # Adjust collision shape size
    if collision_shape:
        var scale_factor = 1.0  # Default scale factor
        collision_shape.scale = Vector2(scale_factor, scale_factor)
    
    # Make sure we're using the normal character
    set_character_state("normal")
    
    # Print debug info
    print("Player initialized on", "MOBILE" if is_mobile else "DESKTOP")
    print("Jump forces - Initial:", get_actual_jump_force(), " Double:", get_actual_double_jump_force(), " Triple:", get_actual_triple_jump_force())

func preload_textures():
    # Load textures in advance to avoid delays when switching
    print("Loading player textures...")
    
    # Try to load the normal texture
    normal_texture = load(character_states["normal"])
    if normal_texture == null:
        push_error("Could not load normal player texture: " + character_states["normal"])
    else:
        print("Normal player texture loaded successfully")
    
    # Try to load the hit texture
    hit_texture = load(character_states["hit"])
    if hit_texture == null:
        push_error("Could not load hit player texture: " + character_states["hit"])
        print("Hit texture not found, will use red tint instead")
    else:
        print("Hit player texture loaded successfully")

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
        velocity.y = min(velocity.y, 1800.0)  # Cap fall speed (increased for better precision)
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
        can_jump = true  # Reset jump availability
    
    # Handle horizontal movement
    var x_diff = target_x_position - global_position.x
    var current_move_speed = move_speed * (mobile_move_speed_multiplier if is_mobile else 1.0)
    
    if abs(x_diff) > 5.0 and (jumping_to_position or is_jumping):
        # Apply horizontal velocity for directional jumps or when moving while jumping
        velocity.x = sign(x_diff) * current_move_speed
    elif abs(x_diff) > 5.0 and !is_jumping:
        # When on ground, move more slowly to destination
        velocity.x = sign(x_diff) * (current_move_speed * 0.7)
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
    
    # Check if jump cooldown has elapsed
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - last_jump_time >= jump_cooldown:
        can_jump = true

# Helper functions to get the correct jump forces based on platform
func get_actual_jump_force():
    return jump_force * (mobile_jump_force_multiplier if is_mobile else 1.0)

func get_actual_double_jump_force():
    return double_jump_force * (mobile_double_jump_force_multiplier if is_mobile else 1.0)

func get_actual_triple_jump_force():
    return triple_jump_force * (mobile_triple_jump_force_multiplier if is_mobile else 1.0)

func _input(event):
    if is_dead:
        return
        
    # Handle keyboard input (for desktop)
    if event.is_action_pressed("jump") and !is_mobile:
        try_jump()
    
    # Handle touch input for directional jumping on mobile
    if is_mobile and event is InputEventScreenTouch and event.pressed:
        handle_mobile_touch(event.position)

# Dedicated function for mobile touch handling
func handle_mobile_touch(touch_position):
    # Store touch position for reference
    last_touch_position = touch_position
    
    # Only process touch events if they're not on UI controls
    var viewport_size = get_viewport_rect().size
    if touch_position.y < viewport_size.y - 150:  # Above the control area
        var touch_x_percent = touch_position.x / screen_width
        
        # On mobile, use a percentage-based approach for more consistent jumps
        if touch_x_percent < 0.5:
            # Left side touch - jump left by a percentage of screen width
            target_x_position = max(global_position.x - (screen_width * mobile_jump_horizontal_distance), screen_margin)
            print("Mobile left jump to:", target_x_position, " (", touch_x_percent * 100, "% of screen)")
        else:
            # Right side touch - jump right by a percentage of screen width
            target_x_position = min(global_position.x + (screen_width * mobile_jump_horizontal_distance), screen_width - screen_margin)
            print("Mobile right jump to:", target_x_position, " (", touch_x_percent * 100, "% of screen)")
        
        # Set flag to indicate directional jump
        jumping_to_position = true
        try_jump()

# Set target position directly (used for touch controls)
func set_target_position(pos_x: float):
    target_x_position = clamp(pos_x, screen_margin, screen_width - screen_margin)
    jumping_to_position = true  # Mark that we're jumping to a position

# Called from directional controls
func move_left():
    if is_mobile:
        target_x_position = max(global_position.x - (screen_width * mobile_jump_horizontal_distance), screen_margin)
    else:
        target_x_position = max(global_position.x - screen_width/4, screen_margin)
    print("Moving left to position:", target_x_position)

func move_right():
    if is_mobile:
        target_x_position = min(global_position.x + (screen_width * mobile_jump_horizontal_distance), screen_width - screen_margin)
    else:
        target_x_position = min(global_position.x + screen_width/4, screen_width - screen_margin)
    print("Moving right to position:", target_x_position)

func try_jump():
    # Don't allow jumping if we're in cooldown or can't jump
    if !can_jump:
        print("Jump blocked by cooldown")
        return false
    
    # Update last jump time and set cooldown
    last_jump_time = Time.get_ticks_msec() / 1000.0
    can_jump = false
    
    # Calculate jump forces based on platform (stronger on mobile)
    var current_jump_force = get_actual_jump_force()
    var current_double_jump_force = get_actual_double_jump_force()
    var current_triple_jump_force = get_actual_triple_jump_force()
    
    # If on floor or haven't jumped yet, do first jump
    if is_on_floor() or global_position.y >= floor_y_position - 20 or !is_jumping:
        jump_count = 1
        velocity.y = current_jump_force
        is_jumping = true
        has_double_jumped = false
        has_triple_jumped = false
        animation_player.play("jump")
        emit_signal("jump_performed")  # Emit signal for sound
        print("First jump with force:", current_jump_force, " (Mobile:", is_mobile, ")")
        return true
        
    # If already jumped once but not twice, do double jump
    elif jump_count == 1:
        jump_count = 2
        velocity.y = current_double_jump_force
        has_double_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")  # Emit signal for sound
        print("Double jump with force:", current_double_jump_force, " (Mobile:", is_mobile, ")")
        return true
        
    # If already double jumped, do triple jump
    elif jump_count == 2:
        jump_count = 3
        velocity.y = current_triple_jump_force
        has_triple_jumped = true
        animation_player.play("double_jump")  # Reuse the same animation
        emit_signal("jump_performed")  # Emit signal for sound
        print("Triple jump with force:", current_triple_jump_force, " (Mobile:", is_mobile, ")")
        return true
        
    # No more jumps available
    return false

func update_animation():
    # Don't update animations when dead
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
    
    print("Player hit! Changing to hit character state")
    
    # Stop any animations to prevent them overriding our texture change
    if animation_player.is_playing():
        animation_player.stop()
    
    # Mark as dead and stop movement
    is_dead = true
    velocity = Vector2.ZERO
    
    # Change character to hit state
    set_character_state("hit")
    
    # Signal that player was hit
    emit_signal("player_hit")

# Set the character state (normal or hit)
func set_character_state(state: String):
    if state in character_states and state != current_character_state:
        print("Changing character state from", current_character_state, "to", state)
        current_character_state = state
        
        # Update the sprite based on the state
        if state == "normal":
            if normal_texture != null:
                sprite.texture = normal_texture
                sprite.modulate = Color.WHITE  # Normal color
            else:
                push_error("Normal texture is null when trying to set character state")
                
        elif state == "hit":
            # Stop any animations to prevent them overriding our texture
            if animation_player.is_playing():
                animation_player.stop()
                
            if hit_texture != null:
                sprite.texture = hit_texture
                sprite.modulate = Color.WHITE  # Normal color
                print("Applied hit texture to player")
            else:
                # Fallback - use normal texture with red tint
                if normal_texture != null:
                    sprite.texture = normal_texture
                    sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)  # Red tint
                    print("Applied red tint fallback for hit state")
                else:
                    push_error("Both hit and normal textures are null")

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
    can_jump = true
    
    # Force position update
    _update_screen_metrics()
    
    target_x_position = screen_width / 2
    global_position = Vector2(target_x_position, floor_y_position - 20)
    velocity = Vector2.ZERO
    sprite.modulate = Color.WHITE  # Reset color
    animation_player.play("idle")
