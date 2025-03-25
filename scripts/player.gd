extends CharacterBody2D
class_name Player

signal player_hit
signal jump_performed  # Signal for jump sound

# Movement parameters
var screen_width: float = 540.0
var screen_margin: float = 50.0
var move_speed: float = 350.0
var target_x_position: float = 270.0
var jumping_to_position: bool = false

# Jump properties
var jump_force: float = -1600.0  # MUCH stronger jumping force
var gravity: float = 2500.0
var double_jump_force: float = -1800.0
var triple_jump_force: float = -2000.0

# Mobile adjustments
var mobile_jump_horizontal_distance = 0.3  # As percentage of screen width

# Character states
var character_states = {
    "normal": "res://assets/sprites/player.svg",
    "hit": "res://assets/sprites/player_hit.svg"
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
var floor_y_position: float = 830.0
var is_mobile = false
var last_jump_time: float = 0.0
var jump_cooldown: float = 0.12  # Very short cooldown
var can_jump = true

# Reference nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
    # Check if we're on mobile
    is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
    
    # Load textures
    preload_textures()
    
    # Wait a frame to ensure viewport size is correct
    await get_tree().create_timer(0.1).timeout
    
    # Force immediate position update
    _update_screen_metrics()
    
    # Adjust collision shape
    if collision_shape and collision_shape.shape:
        collision_shape.scale = Vector2(1.0, 1.0)
    
    # Make sure we're using the normal character
    set_character_state("normal")
    
    # Log a proper initialization message
    print("Player initialized on", "MOBILE" if is_mobile else "DESKTOP")
    print("Jump settings - Force:", jump_force, "Double:", double_jump_force, "Triple:", triple_jump_force)

func preload_textures():
    print("Loading player textures...")
    
    # Normal texture
    normal_texture = load(character_states["normal"])
    if normal_texture:
        print("Normal player texture loaded successfully")
    else:
        push_error("Could not load normal player texture")
    
    # Hit texture
    hit_texture = load(character_states["hit"])
    if hit_texture:
        print("Hit player texture loaded successfully")
    else:
        print("Hit texture not found, will use red tint instead")

func _update_screen_metrics():
    var viewport_rect = get_viewport_rect().size
    screen_width = viewport_rect.x
    
    # Determine floor position
    var floor_offset = 30
    if is_mobile:
        floor_offset = 120  # Higher offset on mobile for controls
    
    floor_y_position = viewport_rect.y - floor_offset
    
    # Position player
    target_x_position = screen_width / 2
    global_position.x = target_x_position
    global_position.y = floor_y_position - 20
    
    print("Screen size:", viewport_rect, "Floor Y:", floor_y_position, "Player position:", global_position)
    
    # Set initial animation
    animation_player.play("idle")

func _physics_process(delta):
    if is_dead:
        return
    
    # Update screen metrics if needed
    var current_viewport_rect = get_viewport_rect().size
    var expected_floor_offset = 120 if is_mobile else 30
    if abs(current_viewport_rect.x - screen_width) > 10 or abs(current_viewport_rect.y - floor_y_position - expected_floor_offset) > 10:
        _update_screen_metrics()
    
    # Apply gravity when airborne
    if not is_on_floor() and global_position.y < floor_y_position:
        velocity.y += gravity * delta
        velocity.y = min(velocity.y, 2000.0)  # Cap fall speed
    else:
        # On floor - reset states
        if global_position.y >= floor_y_position:
            global_position.y = floor_y_position - 10
            velocity.y = 0
            
        # Reset all jump states
        is_jumping = false
        has_double_jumped = false
        has_triple_jumped = false
        jump_count = 0
        jumping_to_position = false
        can_jump = true
    
    # Handle horizontal movement
    var x_diff = target_x_position - global_position.x
    if abs(x_diff) > 5.0:
        var speed_factor = 1.0
        if jumping_to_position or is_jumping:
            speed_factor = 1.0  # Full speed during jumps
        else:
            speed_factor = 0.7  # Slower on ground
        
        velocity.x = sign(x_diff) * move_speed * speed_factor
    else:
        velocity.x = 0
        global_position.x = target_x_position
    
    # Apply movement
    move_and_slide()
    
    # Clamp position horizontally
    global_position.x = clamp(global_position.x, screen_margin, screen_width - screen_margin)
    
    # Ensure player doesn't go below floor
    global_position.y = min(global_position.y, floor_y_position)
    
    # Update animation
    update_animation()
    
    # Update jump cooldown
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - last_jump_time >= jump_cooldown:
        can_jump = true

# This is specific for mobile touch handling
func _input(event):
    if is_dead:
        return
    
    # Desktop input handling
    if event.is_action_pressed("jump") and !is_mobile:
        do_jump_with_logging("keyboard")
    
    # Mobile touch input handling
    if is_mobile and event is InputEventScreenTouch and event.pressed:
        # Check if we're touching in the game area (not UI)
        var viewport_size = get_viewport_rect().size
        if event.position.y < viewport_size.y - 150:
            var touch_x_percent = event.position.x / screen_width
            
            # Set movement direction based on touch position
            if touch_x_percent < 0.5:
                # Left side touch - jump left
                target_x_position = max(global_position.x - (screen_width * mobile_jump_horizontal_distance), screen_margin)
                print("Mobile left jump to:", target_x_position, "(", touch_x_percent * 100, "% of screen)")
            else:
                # Right side touch - jump right
                target_x_position = min(global_position.x + (screen_width * mobile_jump_horizontal_distance), screen_width - screen_margin)
                print("Mobile right jump to:", target_x_position, "(", touch_x_percent * 100, "% of screen)")
            
            # Set jump direction flag
            jumping_to_position = true
            
            # Execute the jump
            do_jump_with_logging("touch at " + str(event.position))

# Set target position directly (used by controls)
func set_target_position(pos_x: float):
    target_x_position = clamp(pos_x, screen_margin, screen_width - screen_margin)
    jumping_to_position = true

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

# Jump with additional logging
func do_jump_with_logging(input_source):
    var result = try_jump()
    print("Jump attempt from " + input_source + ": " + ("SUCCESS" if result else "FAILED"))
    print("  Position: " + str(global_position))
    print("  Jump count: " + str(jump_count) + ", Is jumping: " + str(is_jumping))
    print("  Velocity: " + str(velocity))
    return result

# Original try_jump function
func try_jump():
    # Don't jump if in cooldown
    if !can_jump:
        print("Jump blocked by cooldown")
        return false
    
    # Update jump timing
    last_jump_time = Time.get_ticks_msec() / 1000.0
    can_jump = false
    
    # First jump
    if is_on_floor() or global_position.y >= floor_y_position - 20 or !is_jumping:
        jump_count = 1
        velocity.y = jump_force
        is_jumping = true
        has_double_jumped = false
        has_triple_jumped = false
        animation_player.play("jump")
        emit_signal("jump_performed")
        print("First jump with force:", jump_force)
        return true
    
    # Double jump
    elif jump_count == 1:
        jump_count = 2
        velocity.y = double_jump_force
        has_double_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")
        print("Double jump with force:", double_jump_force)
        return true
    
    # Triple jump
    elif jump_count == 2:
        jump_count = 3
        velocity.y = triple_jump_force
        has_triple_jumped = true
        animation_player.play("double_jump")
        emit_signal("jump_performed")
        print("Triple jump with force:", triple_jump_force)
        return true
    
    return false

func update_animation():
    if is_dead:
        return
    
    if global_position.y < floor_y_position - 20:
        if velocity.y < 0:
            # Rising
            if has_triple_jumped or has_double_jumped:
                animation_player.play("double_jump")
            else:
                animation_player.play("jump")
        elif velocity.y > 0:
            # Falling
            animation_player.play("fall")
    else:
        # On ground
        if abs(velocity.x) > 10:
            animation_player.play("run")
        else:
            animation_player.play("idle")

func hit():
    if is_dead:
        return
    
    print("Player hit! Changing to hit character state")
    
    # Stop animations
    if animation_player.is_playing():
        animation_player.stop()
    
    # Mark as dead and stop
    is_dead = true
    velocity = Vector2.ZERO
    
    # Change character state
    set_character_state("hit")
    
    # Signal hit
    emit_signal("player_hit")

func set_character_state(state: String):
    if state in character_states and state != current_character_state:
        print("Changing character state from", current_character_state, "to", state)
        current_character_state = state
        
        if state == "normal":
            if normal_texture:
                sprite.texture = normal_texture
                sprite.modulate = Color.WHITE
            else:
                push_error("Normal texture is null")
        elif state == "hit":
            # Stop animations
            if animation_player.is_playing():
                animation_player.stop()
            
            if hit_texture:
                sprite.texture = hit_texture
                sprite.modulate = Color.WHITE
                print("Applied hit texture")
            else:
                # Fallback to red tint
                if normal_texture:
                    sprite.texture = normal_texture
                    sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)
                    print("Applied red tint fallback")
                else:
                    push_error("Both textures are null")

func reset():
    print("Resetting player to normal state")
    
    # Reset character state
    set_character_state("normal")
    
    # Reset all flags
    is_dead = false
    is_jumping = false
    has_double_jumped = false
    has_triple_jumped = false
    jump_count = 0
    jumping_to_position = false
    can_jump = true
    
    # Reset position
    _update_screen_metrics()
    
    target_x_position = screen_width / 2
    global_position = Vector2(target_x_position, floor_y_position - 20)
    velocity = Vector2.ZERO
    sprite.modulate = Color.WHITE
    animation_player.play("idle")
