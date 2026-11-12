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

Run the menu boot, settings-persistence and display regression test:

```sh
godot --headless --path . --verbose --script res://tests/boot_smoke_test.gd
```

The physics smoke test checks required scene loading, gameplay player landing, and solid floor, wall, and ceiling collision probes. It also instantiates the real `Scene/player.tscn` in an isolated floor fixture and checks:

- Horizontal acceleration against the configured movement rate.
- Horizontal friction after releasing right movement.
- Grounded jump velocity against the configured jump value.
- Gravity increasing vertical velocity after the jump.
- A second jump press does not reset vertical velocity while the player is airborne.

The real gameplay scene is also checked for a collision-layer contract: every enabled `StaticBody2D` platform must have a non-zero collision layer with at least one bit included in the player's `collision_mask`. The assertion uses bitwise overlap rather than assuming a specific layer number. This covers the current static platforms only; it does not claim coverage for hazards, one-way platforms, moving platforms, or future interactables.

These are regression checks for the current controller, not a final movement-feel approval. Slopes, one-way platforms, moving platforms, hazards, high-speed gameplay movement, corners, and respawn overlap remain untested.

## Settings persistence diagnostics

The boot smoke test uses an isolated `user://latchpoint_settings_smoke_test.cfg` file and removes it after the assertions. It checks:

- First-run defaults when no settings file exists.
- Music-volume and fullscreen save/reload round trips.
- Safe recovery when stored values have the wrong type.
- Clamping of out-of-range numeric audio values.
- Synchronization between the Audio and Settings autoloads.
- Windowed-mode restoration of the borderless flag.

The runtime settings file is `user://settings.cfg`; it is separate from gameplay-progress save data. Audio slider changes are applied immediately and disk writes are debounced. Pending settings are flushed when the Settings autoload exits.

## Audio shutdown diagnostics

- Run both smoke-test commands with `--verbose` and inspect the complete process output, not just the exit code.
- Historical verbose CI runs `42573252526`, `42772371690`, `42772488665` and `42775181753` reported retained `AudioStreamPlaybackMP3` / `AudioStreamMP3` references to `res://Project_bullshit.mp3` after one or both smoke-test processes. The latest inspected run `42978273469` reported the warning after the physics process but not after the boot process.
- The physics smoke test now checks that the AudioStreamPlayer is stopped and has no active playback or stream, then waits for an observed reset in `AudioServer.get_time_since_last_mix()` (maximum 120 process frames) and two more process frames for main-thread cleanup. It logs the audio driver, mix rate, next-mix estimate and wait count.
- Godot headless mode selects the Dummy audio driver. The test must observe an actual mix-age reset; a timeout is a failure. Continue inspecting the full verbose output for retained resources and ObjectDB warnings.
- Latest verified sample, Godot 4.7.2 run [43170548756](https://github.com/Legioniz/LatchPoint/actions/runs/43170548756): Dummy driver, 44,100 Hz, initial next-mix estimate 0.0645 seconds, observed mix reset after 10 process frames. No MP3/ObjectDB shutdown warnings or errors followed either smoke-test process.
- Issue [#3](https://github.com/Legioniz/LatchPoint/issues/3) is resolved as a test-harness timing problem. Keep the mix-cycle assertion and inspect future verbose logs; do not suppress warnings, remove the music check or weaken physics assertions.

## Manual display and audio-settings check

Headless checks cannot confirm how each operating system changes display modes or draws native window decorations. On each supported desktop platform:

1. Launch LatchPoint and confirm it starts in a normal window with a title bar and native decorations on first run.
2. Open Options and enable **Fullscreen**. Confirm the game covers the display.
3. Disable **Fullscreen**. Confirm the game returns to a normal decorated window.
4. Move and resize the window to confirm native window controls are available.
5. Change the Music volume, close the game normally, restart it, and confirm the chosen volume is restored.
6. Restart after selecting Fullscreen and confirm the selected preference is restored. Headless checks do not prove native window-mode behavior.

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
