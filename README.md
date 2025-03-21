# Boomerang Bounce

A tap-only mobile game built with Godot 4.2+, where you jump to avoid a boomerang that comes back faster each round.

![Boomerang Bounce Preview](icon.svg)

## Game Description

Boomerang Bounce is a simple yet addictive tap-to-jump mobile game:

- A boomerang is thrown from the left side of the screen
- It flies in an arc and returns to the starting point
- Player must tap to jump and avoid being hit by the boomerang
- Each successful dodge increases your score
- The boomerang comes back faster with each throw
- Game ends when the player gets hit
- High scores are saved locally

## Technical Details

- Built with Godot 4.2+
- Uses GDScript
- Targets Android API Level 34+ for Google Play compatibility
- No external dependencies or backends required
- Saves high scores locally using Godot's `FileAccess` API
- Designed for portrait mode on mobile devices

## Project Structure

```
BoomerangBounce/
├── assets/
│   ├── sprites/     # Add game sprites here
│   ├── audio/       # Add sound effects and music here
│   └── fonts/       # Add custom fonts here
├── config/
│   └── export_android_hints.txt  # Android export instructions
├── scenes/
│   ├── MainMenu.tscn # Main menu scene
│   ├── Game.tscn     # Main gameplay scene
│   └── GameOver.tscn # Game over scene
├── scripts/
│   ├── boomerang.gd  # Boomerang mechanics
│   ├── player.gd     # Player character controller
│   ├── game_manager.gd # Main game logic
│   ├── main_menu.gd  # Main menu functionality
│   └── game_over.gd  # Game over screen functionality
└── project.godot     # Godot project configuration
```

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

### Important Note About .gdignore Files

If you cannot see the folder contents in the Godot Editor:
1. Check each folder for a `.gdignore` file
2. Delete any `.gdignore` files you find
3. Refresh the FileSystem in the Godot editor

These files were used to maintain the folder structure in Git but they tell Godot to ignore the contents of that folder.

### Adding Custom Assets

1. **Sprites/Images**:
   - Place your sprite files in the `assets/sprites/` directory
   - In Godot, select the appropriate Sprite2D node (e.g., Player, Boomerang)
   - In the Inspector panel, set the Texture property to your sprite file

2. **Audio**:
   - Place your audio files in the `assets/audio/` directory
   - Add an AudioStreamPlayer node to the scene where you want to use the sound
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

To modify the game difficulty, adjust these parameters in `scripts/game_manager.gd`:

- `base_speed_multiplier`: Initial speed of the boomerang
- `speed_increase_per_level`: How much the speed increases after each successful dodge
- `max_difficulty`: Caps the maximum difficulty level

### Modifying Player Physics

To change how the player jumps, adjust these parameters in `scripts/player.gd`:

- `jump_force`: How high the player jumps
- `gravity`: How quickly the player falls back down

### Boomerang Flight Path

To change the boomerang's movement, adjust these parameters in `scripts/boomerang.gd`:

- `flight_speed`: Base movement speed
- `path_height`: Maximum height of the arc
- `path_width`: Horizontal travel distance

## License

This project is open-source and available for personal and commercial use. Feel free to modify and expand upon it as needed.

## Credits

- Created using Godot Engine (https://godotengine.org)
- Developed by [Your Name/Studio]

---

Enjoy building and playing Boomerang Bounce! For issues, suggestions, or contributions, please open an issue or pull request on GitHub.
