# SVG Backgrounds for Boomerang Bounce

This directory contains SVG background templates for the game. Each background is displayed at different score milestones:

1. `background1.svg` - Initial background (score 0-9)
2. `background2.svg` - Second background (score 10-19)
3. `background3.svg` - Third background (score 20-29)
4. `background4.svg` - Fourth background (score 30-39)
5. `background5.svg` - Final background (score 40+)

## Creating Custom SVG Backgrounds

You can use any SVG editor (like Inkscape, Adobe Illustrator, or online tools like Figma) to create or modify these backgrounds.

Here are some guidelines for creating effective backgrounds:

- Keep the design simple and non-distracting, as the player needs to focus on gameplay
- Ensure good contrast with the obstacles and player character
- Consider a gradient or pattern that gets more complex or vibrant as the score increases
- Maintain a 540x960 aspect ratio to match the game's dimensions
- Use layers to create depth (distant mountains, mid-ground elements, etc.)
- Save in SVG format with the same filename to replace the templates

## Implementation

The game automatically switches backgrounds at these score thresholds:
- Score 0-9: background1.svg
- Score 10-19: background2.svg
- Score 20-29: background3.svg
- Score 30-39: background4.svg
- Score 40+: background5.svg

After creating your backgrounds, import them into Godot and update the Background nodes in the Game scene.