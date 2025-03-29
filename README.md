# Obstacle Runner

An endless runner game built with Godot 4.2+, where you move, jump, and double jump to avoid obstacles.

## Features

* **Automatic forward movement**: Obstacles move toward the player, creating the illusion of forward movement
* **Side-to-side movement**: Move between 3 lanes to avoid obstacles
* **Jump/double jump**: Press jump once to jump, and again in mid-air to double jump
* **Basic obstacle avoidance**: Different obstacle types that must be avoided
* **Score counter**: Score increases based on time survived
* **Instant restart**: Press R key or the restart button to immediately restart after game over
* **Dynamic backgrounds**: Background changes every 10 points till 40, then stays at the final background
* **Dynamic audio**: Different sounds play at score milestones and during gameplay
* **Mobile optimized**: Completely rewritten touch controls for reliable jumping on mobile devices

## Controls

- **Left/Right Movement**: Arrow keys, A/D keys, or tap left/right side of screen
- **Jump**: Space, W, Up arrow, or tap center of screen
- **Double Jump**: Press jump again while in the air
- **Restart**: R key or restart button

## Game Mechanics

1. The player automatically progresses through the game
2. Obstacles appear and move toward the player
3. Player must navigate between lanes and jump to avoid obstacles
4. Score increases continuously as you survive
5. When hit by an obstacle, the game ends
6. Press R to immediately restart

## Audio System

The game includes the following audio elements:

1. **Background Music**: Plays continuously during gameplay
2. **Jump Sound**: Plays when jumping or double jumping
3. **Score Sound**: Plays when the score increments
4. **Milestone Sounds**:
   - `milestone5.mp3`: Plays at scores 10, 20, 30, 40
   - `wesopeso.mp3`: Plays at scores 50, 60, 70+
5. **Game Over Sound**: Plays when the player loses

## Background System

The background changes at different score milestones:

1. Initial background (score 0-9)
2. Second background (score 10-19)
3. Third background (score 20-29)
4. Fourth background (score 30-39)
5. Final background (score 40+)

## Project Structure

```
ObstacleRunner/
├── assets/
│   ├── sprites/         # Game sprites and SVG backgrounds
│   ├── audio/           # Sound effects and music
│   └── fonts/           # Custom fonts
├── scenes/
│   ├── MainMenu.tscn        # Main menu
│   ├── Game.tscn            # Main game scene
│   ├── Player.tscn          # Player character
│   ├── Obstacle.tscn        # Generic obstacle
│   ├── GroundObstacle.tscn  # Low obstacles requiring lane change
│   └── AirObstacle.tscn     # High obstacles requiring jump
├── scripts/
│   ├── player.gd            # Player controls and physics
│   ├── obstacle.gd          # Obstacle behavior
│   ├── obstacle_manager.gd  # Spawns and manages obstacles
│   ├── game_manager.gd      # Game state and UI management
│   └── main_menu.gd         # Main menu functionality
└── project.godot            # Godot project configuration
```

## Setup Instructions

1. Install Godot 4.2+ (Standard Version)
2. Clone this repository
3. Place the required audio files in the `assets/audio/` directory:
   - `background.mp3` - Background music
   - `jump.mp3` - Jump sound effect
   - `score.mp3` - Score increment sound
   - `milestone5.mp3` - Milestone sound (10, 20, 30, 40 points)
   - `wesopeso.mp3` - Milestone sound (50+ points)
   - `game-over.mp3` - Game over sound
4. Open the project in Godot Engine by selecting the `project.godot` file
5. Press F5 or the "Play" button to run the game

## Customization

### Modifying Backgrounds

You can customize the SVG backgrounds in the `assets/sprites/` directory:
- `background1.svg` - Initial background (score 0-9)
- `background2.svg` - Second background (score 10-19)
- `background3.svg` - Third background (score 20-29)
- `background4.svg` - Fourth background (score 30-39)
- `background5.svg` - Final background (score 40+)

Use any SVG editor like Inkscape, Adobe Illustrator, or online tools to modify these files.

### Modifying Audio

Replace the audio files in the `assets/audio/` directory with your own sounds.
After adding custom audio, you may need to reimport them in Godot and update their properties.

<!-- REMOVED_FEATURE_TAG -->
## Removed Boomerang Feature

This version of the game has had the boomerang obstacle mechanics removed. The following changes were made:

1. Removed the boomerang scene reference from Game.tscn
2. Removed the boomerang_scene reference from obstacle_manager.gd
3. Removed the boomerang.gd script
4. Removed the Boomerang.tscn scene

The game now only includes standard obstacles that appear from the right side of the screen. The original boomerang mechanics featured a special obstacle that followed an arc path and could loop back toward the player.

This removal simplifies the game mechanics while maintaining the core endless runner experience.

If you need to restore the boomerang feature in a future version, check the commit history or reference the original repository.
<!-- END_REMOVED_FEATURE_TAG -->

<!-- TROUBLESHOOTING_TAG -->
## Troubleshooting Guide

If you encounter issues with this game, please check the following:

### Common Issues and Solutions

1. **Mobile Controls Issues**
   - If default mobile controls (gray squares, jump label) appear, check `project.godot` settings under display/window/handheld
   - Set touchscreen_button_visibility to false

2. **Mobile Jump Not Working** (FIXED March 2025)
   - This issue has been completely resolved with a major overhaul to mobile input handling
   - The fix implements a direct approach to mobile jumping with the following changes:
     - Created a new `force_mobile_jump()` function that directly sets jump velocity
     - Improved touch detection in both player and game_manager scripts
     - Added input debouncing to prevent accidental double jumps
     - Implemented dedicated touch handling for directional jumps

3. **Particle Effects Errors**
   - If seeing "Invalid set index 'scale_amount'" errors, check Godot version compatibility
   - For Godot 3.x: use scale_amount property
   - For Godot 4.x: use scale_amount_min and scale_amount_max properties

4. **Game Ending Unexpectedly**
   - This may be due to obstacle collisions - try adjusting player collision shape
   - Make sure JumpEffect scene doesn't have CPUParticles2D using incompatible properties

### Recent Fixes

1. **Major Mobile Input Overhaul** (March 2025)
   - Completely rewrote the jumping mechanics for mobile devices
   - Fixed touch input detection and processing for more reliable jumping
   - Added both direct touch and button-based jump methods
   - Implemented clear separation between mobile and desktop input handling
   - Made touch input work on any part of the screen with directional detection

### When Reporting Issues

Please include:
- Godot version number
- Full error message text
- When/where the error occurs
- Screenshot if applicable
- Platform (desktop or specific mobile device type)

Reference this troubleshooting section when opening new support requests.
<!-- END_TROUBLESHOOTING_TAG -->
