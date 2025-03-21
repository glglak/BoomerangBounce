# Boomerang Bounce

An endless runner game built with Godot 4.2+, where you move, jump, and double jump to avoid obstacles.

## One-Day Prototype

This is a minimum viable prototype with just the essential features:

* **Automatic forward movement**: The game simulates forward movement by having obstacles move toward the player
* **Side-to-side movement**: Player can move between 3 lanes to avoid obstacles
* **Jump/double jump**: Press jump once to jump, and again in mid-air to double jump
* **Basic obstacle avoidance**: Different obstacle types that must be avoided
* **Score counter**: Score increases based on time survived
* **Instant restart**: Press R key or the restart button to immediately restart after game over

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

## Project Structure

```
BoomerangBounce/
├── assets/          # Game sprites, audio, and fonts
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
3. Open the project in Godot Engine by selecting the `project.godot` file
4. Press F5 or the "Play" button to run the game
