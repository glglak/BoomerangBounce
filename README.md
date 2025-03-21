# Boomerang Bounce

A platformer action game built with Godot 4.2+, where you move, jump, and double jump to avoid obstacles.

![Boomerang Bounce Preview](icon.svg)

## One-Day Prototype

This is a minimum viable prototype of the Boomerang Bounce game with just the essential features:

- Automatic forward movement
- Side-to-side movement (3 lanes)
- Jump and double jump mechanics
- Basic obstacle avoidance
- Score counter based on distance traveled
- Instant restart functionality

## Game Description

Boomerang Bounce is an exciting mobile platformer with simple controls and addictive gameplay:

- Move left and right with on-screen controls
- Jump and double jump to navigate platforms
- Avoid spinning obstacles that approach from the right
- Each successfully avoided obstacle increases your score
- Obstacles come faster as your score increases
- Game ends when an obstacle hits you
- High scores are saved locally
- Features stationary and moving platforms to traverse

## Technical Details

- Built with Godot 4.2+
- Uses GDScript
- Targets Android API Level 34+ for Google Play compatibility
- No external dependencies or backends required
- Saves high scores locally using Godot's `FileAccess` API
- Designed for portrait mode on mobile devices
- Custom on-screen controls for movement and jumping
- Physics-based character movement with double jump mechanics

## Project Structure

```
BoomerangBounce/
├── assets/
│   ├── sprites/         # Game sprites (SVG format)
│   ├── audio/           # Sound effects and music
│   └── fonts/           # Custom fonts
├── config/
│   └── export_android_hints.txt  # Android export instructions
├── scenes/
│   ├── MainMenu.tscn    # Main menu scene
│   ├── Game.tscn        # Main gameplay scene
│   ├── GameOver.tscn    # Game over scene
│   ├── Player.tscn      # Player character prefab
│   ├── Platform.tscn    # Platform prefab
│   ├── Obstacle.tscn    # Obstacle prefab 
│   └── Controls.tscn    # On-screen controls
├── scripts/
│   ├── player.gd             # Player physics and controls
│   ├── obstacle.gd           # Obstacle behavior
│   ├── obstacle_manager.gd   # Spawns and manages obstacles
│   ├── platform.gd           # Platform behavior, including moving platforms
│   ├── controls_manager.gd   # On-screen control handling
│   ├── game_manager.gd       # Main game logic
│   ├── main_menu.gd          # Main menu functionality
│   └── game_over.gd          # Game over screen functionality
└── project.godot             # Godot project configuration
```

## Controls

- **Left/Right Movement**: On-screen arrow buttons (or A/D keys)
- **Jump**: On-screen jump button (or W/Space/Up arrow keys)
- **Double Jump**: Press jump again while in the air
- **Restart**: R key or the restart button in the UI

## Setup Instructions

### Development Environment

1. Install Godot 4.2+ (Standard Version, not .NET)
   - Download from [Godot's official website](https://godotengine.org/download/)
   - For Android development, you'll also need the Android Build Template

2. Clone this repository:
   ```bash
   git clone https://github.com/glglak/BoomerangBounce.git
   ```

3. Open Godot Engine and import the project by selecting the `project.godot` file

### Running the Game Locally

1. Open the project in Godot
2. Click the "Play" button in the top right or press F5
3. The game should start from the main menu scene

## License

This project is open-source and available for personal and commercial use. Feel free to modify and expand upon it as needed.

## Credits

- Created using Godot Engine (https://godotengine.org)

---

Enjoy building and playing Boomerang Bounce! For issues, suggestions, or contributions, please open an issue or pull request on GitHub.
