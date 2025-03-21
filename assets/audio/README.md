# Audio Files for Boomerang Bounce

Place the following audio files in this directory:

1. `background.mp3` - Background music that plays during gameplay
2. `jump.mp3` - Sound effect for jump and double jump actions
3. `score.mp3` - Sound effect played when score increments
4. `milestone5.mp3` - Sound effect played at scores 10, 20, 30, 40
5. `wesopeso.mp3` - Sound effect played at scores 50, 60, 70+
6. `game-over.mp3` - Sound effect played when the player loses

## Importing Audio Files

After placing the audio files in this directory, you'll need to import them in Godot:

1. Open the Godot project
2. In the FileSystem panel, locate the files in the `assets/audio/` directory
3. Select the files and adjust their import settings as needed:
   - For music: Enable looping, set compression mode to 'Lossy' or 'Lossless'
   - For sound effects: Disable looping, adjust compression as needed

## Audio Bus Configuration

The game uses two audio buses:
- `Music` for background music
- `SFX` for all sound effects

If these buses don't exist, you'll need to create them in the Audio settings.