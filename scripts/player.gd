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

# Mobile/Desktop Detection
var is_mobile = false

# Jump properties - DRASTICALLY STRONGER
var base_jump_force: float = -1500.0
var base_double_jump_force: float = -1700.0
var base_triple_jump_force: float = -1900.0

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
var last_jump_time: float = 0.0  # Track the last time a jump was performed
var can_jump = true  # Flag for jump availability
var gravity_value = 2500.0  # Gravity force
var jump_processing = false  # Flag to prevent multiple jump calls

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
    # Check if we're on mobile
    is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
    print("PLATFORM: " + ("MOBILE" if is_mobile else "DESKTOP"))
    
    # Setup input mapping for jumping
    if not InputMap.has_action("jump"):
        InputMap.add_action("jump")
        var space_key = InputEventKey.new()
        space_key.keycode = KEY_SPACE
        InputMap.action_add_event("jump", space_key)
    
    # Preload textures
    preload_textures()
    
    # Wait a frame to ensure viewport size is correct
    await get_tree().process_frame
    
    # Force immediate position update
    _update_screen_metrics()
    
    # Make sure we're using the normal character
    set_character_state("normal")
    
    # Add a click input action
    if not InputMap.has_action("click"):
        InputMap.add_action("click")
        var click_event = InputEventMouseButton.new()
        click_event.button_index = MOUSE_BUTTON_LEFT
        InputMap.action_add_event("click", click_event)
        
    # Print jump forces
    print("Jump forces: ", base_jump_force, " / ", base_double_jump_force, " / ", base_triple_jump_force)

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
    
    # Set floor position based on platform
    var floor_offset = 30
    if is_mobile:
        # On mobile, position higher to avoid controls at bottom
        floor_offset = 120  # Higher offset to stay above control panel
    
    # Calculate floor position to be above the bottom of the screen
    floor_y_position = viewport_rect.y - floor_offset
    
    # Start in the middle of the screen
    target_x_position = screen_width / 2
    global_position.x = target_x_position
    global_position.y = floor_y_position - 20  # Start slightly above floor
    
    # Log screen metrics for debugging
    print("Screen size: ", viewport_rect, " Floor Y: ", floor_y_position, " Player position: ", global_position)
    
    # Set initial animation
    animation_player.play("idle")

func _physics_process(delta):
    if is_dead:
        return
    
    # Apply gravity
    if not is_on_floor() and global_position.y < floor_y_position:
        velocity.y += gravity_value * delta
        velocity.y = min(velocity.y, 2000.0)  # Cap fall speed
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
        jumping_to_position = false
        jump_processing = false
        can_jump = true
    
    # Handle horizontal movement
    var x_diff = target_x_position - global_position.x
    var current_move_speed = move_speed * (1.5 if is_mobile else 1.0)
    
    if abs(x_diff) > 5.0:
        # Apply horizontal velocity
        velocity.x = sign(x_diff) * current_move_speed
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

# Handle all input events
func _unhandled_input(event):
    if is_dead:
        return
    
    # Desktop keyboard input
    if not is_mobile and event.is_action_pressed("jump"):
        perform_jump()
    
    # Desktop mouse input
    if not is_mobile and event.is_action_pressed("click") and event is InputEventMouseButton:
        handle_directional_input(event.position)
    
    # Mobile touch input
    if is_mobile and event is InputEventScreenTouch and event.pressed:
        print("Touch detected at: ", event.position)
        handle_directional_input(event.position)

# Handle directional jump input
func handle_directional_input(input_pos):
    # Only process touches if they're not on UI controls
    var viewport_size = get_viewport_rect().size
    if input_pos.y < viewport_size.y - 150:  # Above control area
        print("Processing directional input")
        
        # Calculate horizontal direction
        var input_x_percent = input_pos.x / screen_width
        var horizontal_distance = screen_width * 0.3
        
        if input_x_percent < 0.5:
            # Left side input - jump left
            target_x_position = max(global_position.x - horizontal_distance, screen_margin)
            print("Jump left to: ", target_x_position)
        else:
            # Right side input - jump right
            target_x_position = min(global_position.x + horizontal_distance, screen_width - screen_margin)
            print("Jump right to: ", target_x_position)
        
        # Flag to indicate directional jump
        jumping_to_position = true
        perform_jump()

# Perform jump with appropriate force
func perform_jump():
    if jump_processing:
        print("Jump already in progress, ignoring")
        return
    
    jump_processing = true
    print("Attempting jump with count: ", jump_count)
    
    # Calculate jump forces - much stronger on mobile
    var jump_force = base_jump_force * (2.0 if is_mobile else 1.0)
    var double_jump_force = base_double_jump_force * (2.0 if is_mobile else 1.0)
    var triple_jump_force = base_triple_jump_force * (2.0 if is_mobile else 1.0)
    
    # First jump
    if is_on_floor() or global_position.y >= floor_y_position - 20 or !is_jumping:
        jump_count = 1
        velocity.y = jump_force
        is_jumping = true
        animation_player.play("jump")
        emit_signal("jump_performed")
        print("FIRST JUMP with force: ", jump_force)
    
    # Double jump    
    elif jump_count == 1:
        jump_count = 2
        velocity.y = double_jump_force
        has_double_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")
        print("DOUBLE JUMP with force: ", double_jump_force)
    
    # Triple jump
    elif jump_count == 2:
        jump_count = 3
        velocity.y = triple_jump_force
        has_triple_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")
        print("TRIPLE JUMP with force: ", triple_jump_force)
    
    # Small delay before allowing next jump
    await get_tree().create_timer(0.1).timeout
    jump_processing = false

# Update character animation based on state
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

# Handle player hit
func hit():
    if is_dead:
        return
    
    print("Player hit! Changing to hit character state")
    
    # Stop any animations
    if animation_player.is_playing():
        animation_player.stop()
    
    # Mark as dead and stop movement
    is_dead = true
    velocity = Vector2.ZERO
    
    # Change character state
    set_character_state("hit")
    
    # Signal hit
    emit_signal("player_hit")

# Set the character state (normal or hit)
func set_character_state(state: String):
    if state in character_states and state != current_character_state:
        print("Changing character state from", current_character_state, "to", state)
        current_character_state = state
        
        # Update sprite texture
        if state == "normal" and normal_texture != null:
            sprite.texture = normal_texture
            sprite.modulate = Color.WHITE
        elif state == "hit":
            if hit_texture != null:
                sprite.texture = hit_texture
                sprite.modulate = Color.WHITE
                print("Applied hit texture to player")
            else:
                # Fallback to red tint
                sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)

# Reset player state
func reset():
    print("Resetting player to normal state")
    
    set_character_state("normal")
    
    is_dead = false
    is_jumping = false
    has_double_jumped = false
    has_triple_jumped = false
    jump_count = 0
    jumping_to_position = false
    jump_processing = false
    can_jump = true
    
    _update_screen_metrics()
    
    target_x_position = screen_width / 2
    global_position = Vector2(target_x_position, floor_y_position - 20)
    velocity = Vector2.ZERO
    animation_player.play("idle")
