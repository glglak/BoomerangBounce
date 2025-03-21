# Boomerang Bounce

A platformer action game built with Godot 4.2+, where you move, jump, and double jump to avoid obstacles.

![Boomerang Bounce Preview](icon.svg)

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

### Adding Custom Assets

1. **Sprites/Images**:
   - You can replace the SVG files in the `assets/sprites/` directory with your own
   - Or use the existing SVG files as templates to create your own art
   - The game uses SVG files which scale nicely across different resolutions

2. **Audio**:
   - Place your audio files in the `assets/audio/` directory
   - Add AudioStreamPlayer nodes to the scenes where you want to use the sound
   - In the Inspector panel, set the Stream property to your audio file

3. **Fonts**:
   - Place your font files in the `assets/fonts/` directory
   - Select a Label or other UI text element
   - In the Inspector, expand the Theme Overrides > Fonts section
   - Set the font property to your custom font file

## Building for Android

### Prerequisites

1. Install Android Studio and Android SDK
2. Install the appropriate Android Build Template in Godot
3. Configure Android SDK path in Godot's Editor Settings

### Setting Up Export Templates

1. In Godot, go to Project > Export
2. Click "Add..." and select "Android"
3. Configure the preset according to instructions in `config/export_android_hints.txt`
4. Create a keystore file for signing your app

### Exporting an AAB (Android App Bundle)

1. In the Export dialog, select your Android preset
2. Choose "Export Project" (not "Export PCK/ZIP")
3. Enable "Use Gradle Build"
4. Select "Export Format: AAB"
5. Click "Export" and choose a destination

### Testing the AAB

1. You can use bundletool to convert your AAB to a set of APKs for testing:
   ```bash
   bundletool build-apks --bundle=path/to/your/app.aab --output=path/to/your/app.apks
   bundletool install-apks --apks=path/to/your/app.apks
   ```

2. Alternatively, upload the AAB to Google Play's internal testing track

## Customization Tips

### Adjusting Game Difficulty

To modify the game difficulty, adjust these parameters in `scripts/obstacle_manager.gd`:

- `min_speed` and `max_speed`: Control how fast obstacles move
- `speed_increase_rate`: How quickly the game gets harder
- `min_obstacle_distance` and `max_obstacle_distance`: Spacing between obstacles

### Modifying Player Physics

To change how the player moves and jumps, adjust these parameters in `scripts/player.gd`:

- `movement_speed`: Horizontal movement speed
- `jump_force`: How high the player jumps
- `gravity`: How quickly the player falls back down
- `double_jump_force`: How powerful the second jump is

### Platform Configuration

To change platform behavior, modify parameters in `scripts/platform.gd` or in the Platform scene instances:

- `is_moving`: Whether the platform moves
- `move_speed`: How fast the platform moves
- `move_distance`: How far the platform moves
- `move_direction`: Which direction the platform moves

## License

This project is open-source and available for personal and commercial use. Feel free to modify and expand upon it as needed.

## Credits

- Created using Godot Engine (https://godotengine.org)

---

Enjoy building and playing Boomerang Bounce! For issues, suggestions, or contributions, please open an issue or pull request on GitHub.
