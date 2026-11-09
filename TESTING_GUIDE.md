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

Run the deterministic scene and physics smoke test:

```sh
godot --headless --path . --verbose --script res://tests/physics_smoke_test.gd
```

Run the menu boot and display-settings regression test:

```sh
godot --headless --path . --verbose --script res://tests/boot_smoke_test.gd
```

The physics smoke test currently checks scene loading, player landing, and solid floor, wall, and ceiling collision probes. It does not yet cover slopes, one-way platforms, moving platforms, hazards, or high-speed gameplay movement.

The boot test checks the menu controls and verifies that the fullscreen toggle initializes windowed mode with decorations and restores decorations when switched back to windowed mode.

## Manual display-settings check

Headless checks cannot confirm how each operating system draws native window decorations. On each supported desktop platform:

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
