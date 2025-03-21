# Boomerang Bounce

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

## Controls

- **Left/Right Movement**: Arrow keys, A/D keys, or on-screen buttons
- **Jump**: Space, W, Up arrow, or on-screen button
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
BoomerangBounce/
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
