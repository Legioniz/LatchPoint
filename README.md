# LatchPoint

LatchPoint is an early Godot 4.7 2D game prototype. The repository currently contains a player controller, platform collision geometry, a main menu, a new/load menu, options, audio and a pause menu. The definitive core gameplay loop is still being established; future features must support a deliberate design goal rather than being added randomly.

## Run the project

1. Install Godot 4.7.x (standard build; the project currently uses GDScript).
2. Open `project.godot` in Godot.
3. Let Godot import the project's resources.
4. Run the project with **F6/F5** or the Run Project button.

Current scene flow:

`menu.tscn` → `new_load.tscn` → `Scene/main.tscn`

## Current controls

The player uses Godot's built-in input actions:

- `ui_left` / `ui_right`: horizontal movement
- `ui_accept`: jump
- `ui_cancel`: pause / resume while in gameplay

Review **Project Settings → Input Map** for the active key bindings.

## Current status

- Player movement uses configurable speed, acceleration, friction and jump velocity.
- The game scene contains static collision platforms and a player collision shape.
- The pause menu is attached to the gameplay scene.
- Music and display settings are connected to the options screen.
- Load Game is intentionally disabled until a real save/load system exists.
- The current dark gameplay background is a safe fallback; final environment art awaits a confirmed visual direction.

## Development and validation

Read [DEVELOPMENT_PLAYBOOK.md](DEVELOPMENT_PLAYBOOK.md) before making substantial changes. Use [IMPROVEMENT_BACKLOG.md](IMPROVEMENT_BACKLOG.md) for priorities, [IMPROVEMENT_LOG.md](IMPROVEMENT_LOG.md) for completed work, and [RESEARCH_REGISTER.md](RESEARCH_REGISTER.md) for external game/design/engine references.

The repository includes a headless smoke/physics test at `tests/physics_smoke_test.gd` and a GitHub Actions workflow at `.github/workflows/godot-validation.yml`.

Run locally from the project root:

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/physics_smoke_test.gd
godot --headless --path . --quit-after 120
```

A test is considered passed only when its command actually completes successfully. Headless checks do not replace hands-on playtesting, visual review or testing on the target hardware.
