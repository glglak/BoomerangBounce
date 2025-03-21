# Customizing Boomerang Bounce

This guide provides information on customizing the game's visuals and gameplay elements.

## Character Customization

The player character is defined in `scenes/Player.tscn` and uses the following dimensions:

- **Size:** Approximately 50x60 pixels
- **Position:** Centered in one of three lanes (x = 100, 270, or 440)
- **Floor position:** y = 800 pixels from the top
- **Animation states:** idle, run, jump, double_jump, fall

To create a custom character:

1. Create a new sprite in your preferred editor (SVG format recommended)
2. Replace the sprite in `Player.tscn`
3. Adjust the collision shape if needed
4. If creating animations, match the existing animation names or update the player.gd script

## Background Customization

The game uses SVG backgrounds that change as the player scores points:

1. **Background Dimensions:**
   - Width: 540 pixels
   - Height: 960 pixels
   - Aspect ratio: 9:16 (portrait mode)

2. **Background Files:**
   - `assets/sprites/background1.svg` - Initial background (score 0-9)
   - `assets/sprites/background2.svg` - Second background (score 10-19)
   - `assets/sprites/background3.svg` - Third background (score 20-29)
   - `assets/sprites/background4.svg` - Fourth background (score 30-39)
   - `assets/sprites/background5.svg` - Final background (score 40+)

3. **Design Guidelines:**
   - Keep the ground area clear (approximately y=800 to y=960)
   - Ensure good contrast with player and obstacles
   - Consider creating a visual progression across backgrounds
   - SVG format allows for easy scaling across different resolutions

## Obstacle Customization

The game has three types of obstacles:

1. **Ground Obstacles (`GroundObstacle.tscn`):**
   - Size: Approximately 64x20 pixels
   - Position: y = 790 pixels (ground level)
   - Best for requiring lane changes

2. **Air Obstacles (`AirObstacle.tscn`):**
   - Size: Approximately 20x64 pixels
   - Position: y = 730 pixels (above ground)
   - Best for requiring jumps

3. **Standard Obstacles (`Obstacle.tscn`):**
   - Size: Approximately 48x48 pixels (circular)
   - Position: varies
   - Generic obstacle type

To customize obstacles:

1. Edit the obstacle scenes in Godot
2. Replace sprites with your own designs
3. Adjust collision shapes if needed
4. Modify rotation speed in the `obstacle.gd` script

## Adjusting Game Difficulty

Game difficulty is controlled in `scripts/obstacle_manager.gd`:

- `min_spawn_interval` and `max_spawn_interval`: Control how frequently obstacles appear
- `initial_obstacle_speed`: Initial movement speed of obstacles
- `max_obstacle_speed`: Maximum speed obstacles can reach
- `speed_increase_rate`: How quickly obstacles accelerate as the game progresses

For the player character in `scripts/player.gd`:
- `jump_force`: How high the player jumps
- `double_jump_force`: How high the double jump goes
- `gravity`: How quickly the player falls back down
- `lane_change_speed`: How quickly the player moves between lanes

## Adding Custom Audio

The game uses the following audio files:

1. `assets/audio/background.mp3` - Background music
2. `assets/audio/jump.mp3` - Jump sound effect
3. `assets/audio/score.mp3` - Score increment sound
4. `assets/audio/milestone5.mp3` - Milestone sound (10, 20, 30, 40 points)
5. `assets/audio/wesopeso.mp3` - Milestone sound (50+ points)
6. `assets/audio/game-over.mp3` - Game over sound

To add custom audio:
1. Create audio files in your preferred format (MP3 recommended)
2. Place them in the `assets/audio/` directory with the correct names
3. Import them in Godot, setting appropriate properties (looping for music, etc.)
