# Testing Guide

## Requirements

- Godot 4.7.x standard build (CI pins 4.7.2).
- Open the repository root as a Godot project.
- Allow the editor to import resources before launching the game.

## Automated validation

Run from the repository root:

```sh
godot --headless --editor --path . --import
```

Parse every tracked GDScript file:

```sh
set -euo pipefail
while IFS= read -r script; do
  godot --headless --path . --check-only --script "res://$script"
done < <(git ls-files '*.gd' | sort)
```

Run the deterministic scene, physics and player-movement smoke test:

```sh
godot --headless --path . --verbose --script res://tests/physics_smoke_test.gd
```

Run the menu boot and display-settings regression test:

```sh
godot --headless --path . --verbose --script res://tests/boot_smoke_test.gd
```

The physics smoke test checks required scene loading, gameplay player landing, and solid floor, wall, and ceiling collision probes. It also instantiates the real `Scene/player.tscn` in an isolated floor fixture and checks:

- Horizontal acceleration against the configured movement rate.
- Horizontal friction after releasing right movement.
- Grounded jump velocity against the configured jump value.
- Gravity increasing vertical velocity after the jump.
- A second jump press does not reset vertical velocity while the player is airborne.

These are regression checks for the current controller, not a final movement-feel approval. They do not yet cover slopes, one-way platforms, moving platforms, hazards, high-speed gameplay movement, corners, collision masks, or respawn overlap.

## Audio shutdown diagnostics

- Run both smoke-test commands with `--verbose` and inspect the complete process output, not just the exit code.
- The observed CI run `42573252526` passes its physics assertions but the physics-test process then reports retained `AudioStreamPlaybackMP3` / `AudioStreamMP3` references to `res://Project_bullshit.mp3`. The boot-test process in that same job did not show the same warning in the inspected log.
- The test currently calls `Audio.shutdown_audio()` and waits two process frames. This has not yet been demonstrated to release the AudioServer's playback-list reference before process shutdown.
- Track investigation in [issue #3](https://github.com/Legioniz/LatchPoint/issues/3). Do not hide the warning or remove the music check to make CI appear clean. A fix is accepted only after the verbose CI logs show the expected shutdown behavior or the engine limitation is reproduced and documented.

## Manual display-settings check

Headless checks cannot confirm how each operating system changes display modes or draws native window decorations. On each supported desktop platform:

1. Launch LatchPoint and confirm it starts in a normal window with a title bar and native decorations.
2. Open Options and enable **Fullscreen**. Confirm the game covers the display.
3. Disable **Fullscreen**. Confirm the game returns to a normal decorated window.
4. Move and resize the window to confirm native window controls are available.
5. Restart the game and confirm the default windowed presentation is restored.

Record the operating system, display setup, Godot version, and observed result in the improvement log. Do not mark platform-specific manual verification complete based only on headless CI.

## Physics debugging

- Enable **Debug → Visible Collision Shapes** in the running editor/game.
- Compare the player sprite with its CollisionShape2D.
- Reproduce floor, wall, and ceiling contact using the existing smoke test before changing movement or collision geometry.
- Add a deterministic regression case whenever a physics defect is fixed.
- Record scenarios not exercised by automation as unverified.

## Agent and performance testing

No reinforcement-learning agent is currently part of the project. Use deterministic or seeded scripted input tests where a measurable objective exists; do not label those tests as machine learning.

Do not claim performance improvements without recording comparable before/after measurements on the same target hardware and project state.
