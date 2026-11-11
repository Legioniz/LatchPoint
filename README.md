# LatchPoint

**LatchPoint** is an early 2D platform-game prototype built with Godot Engine 4.7. The repository contains a player scene and movement script, a test environment, menu/pause/options scenes, audio-control scripts, and imported visual/audio assets.

## Open the project

1. Install Godot **4.7**.
2. Clone or download this repository.
3. Open the repository's `project.godot` file in the Godot Project Manager.
4. Run the configured main scene from the editor.

The project currently uses the Godot Forward+ renderer and its built-in input actions.

## Current controls

| Action | Input action |
|---|---|
| Move left | `ui_left` |
| Move right | `ui_right` |
| Jump | `ui_accept` (typically Space or Enter, depending on the active input map) |

The player is a `CharacterBody2D` with gravity and floor-based jump handling. The main test scene includes a follow camera with smoothing and simple collision geometry.

## Included systems

- Main menu, pause menu, and options menu scenes.
- Separate scripts for audio and music controls.
- Player scene and a basic 2D movement controller.
- Imported character, background, icon, and audio assets.

## Current status and limitations

This is a prototype, not a finished game or release-ready platformer. The player movement script is still in progress; its horizontal movement calculations currently contain overlapping logic that should be consolidated before movement is treated as final. Scene layout, controls, audio, and imported assets may change as development continues.

No automated test suite or exported game build is included in the current repository.

## Repository hygiene

Godot's generated `.godot/` cache and Android export output are ignored. Keep editor caches, local logs, and operating-system metadata out of commits. Preserve the `.uid` and `.import` files that belong to project assets.

