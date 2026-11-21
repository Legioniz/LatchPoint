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

- Run both smoke-test commands with `--verbose` and inspect the complete process output after each process, not just the exit code.
- Both processes must stop and clear their AudioStreamPlayer, assert that no playback or stream remains, observe a reset in `AudioServer.get_time_since_last_mix()` (maximum 120 process frames), and allow two more process frames for main-thread cleanup. Each process has an independent AudioServer lifecycle.
- Godot headless mode selects the Dummy audio driver. A missing mix-age reset is a test failure.
- In final Godot 4.7.2 run [43174879566](https://github.com/Legioniz/LatchPoint/actions/runs/43174879566), the physics process observed a mix reset after 10 frames and the boot process after 2 frames (Dummy driver, 44,100 Hz). The complete verbose job log contains no retained MP3/ObjectDB warnings, `ERROR` or `WARNING` lines after either process. Issue [#3](https://github.com/Legioniz/LatchPoint/issues/3) is resolved on this branch; leave it open until the stacked change is integrated.
- After consolidating the shared verifier, run [44255209541](https://github.com/Legioniz/LatchPoint/actions/runs/44255209541) passed both independent processes: physics observed the Dummy-driver mix reset after 9 frames and boot after 13 frames (44,100 Hz). The complete process output contains no retained MP3/ObjectDB/StringName diagnostics or Godot errors. The inherited checkout action still emits a Node.js 20 deprecation warning; see PR #11.


The shutdown contract is implemented once in `tests/audio_shutdown_verifier.gd`. Each smoke-test process invokes it independently: the physics test requires background playback to have started, while the boot test verifies cleanup without imposing that extra precondition. Keep the per-process calls; one process cannot clean up another process's AudioServer state.

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

## Settings persistence lifecycle regression

The boot smoke test covers both the settings data rules and the real debounce/teardown path:

- Missing file uses safe defaults.
- Valid audio/display values survive a ConfigFile save/reload round trip.
- Invalid value types and out-of-range audio values recover to validated defaults.
- Music bus changes synchronize with the Settings autoload.
- An in-tree Settings fixture starts its 0.5-second debounce Timer; the test verifies the file is still absent before the timer can process.
- Freeing that fixture invokes the exit-tree callback. The test reloads the isolated file and verifies the latest preference was flushed.

The temporary file is user://latchpoint_settings_smoke_test.cfg and is removed after the test. This is an in-process lifecycle test, not a separate-process application restart test. Keep manual desktop fullscreen/restart verification separate from headless CI.


## Combined settings/audio lifecycle integration

The integration branch combines the settings lifecycle regression with the shared audio shutdown verifier:

- The physics smoke test requires that background playback started before shutdown.
- The boot smoke test retains its settings debounce/exit-tree, audio-settings synchronization, and display-decoration checks.
- Both tests stop and clear the AudioStreamPlayer, verify no stream/playback remains, observe a mix-age reset within 120 process frames, and wait two additional process frames.
- Each smoke-test command is a separate Godot process. Inspect the complete verbose log after each process; a successful exit code alone is not sufficient evidence of clean shutdown.
- The settings test continues to use and remove only its isolated `user://latchpoint_settings_smoke_test.cfg` file.

Godot 4.7.2 run [44689407205](https://github.com/Legioniz/LatchPoint/actions/runs/44689407205) verified the combined branch: physics observed a Dummy-driver mix reset after 7 process frames and boot after 9 frames, both at 44,100 Hz. The full verbose log contained no retained ObjectDB/MP3/StringName diagnostics after either process. Issue [#3](https://github.com/Legioniz/LatchPoint/issues/3) remains open until the dependent stack reaches the default branch. Do not suppress retention diagnostics.


## Menu keyboard/controller focus regression

The boot smoke test now dispatches keyboard events through the viewport and checks the existing menu flow:

- Main menu starts on Play and follows Play → Settings → Quit with Up/Down.
- New/load menu starts on New Game; disabled Load Game remains disabled and cannot receive focus.
- Options starts on the Music slider and follows Music → Fullscreen → Return.
- Escape opens the pause menu and focuses Resume.
- Pause navigation follows Resume → Return To Menu → Quit.
- Space activates the focused Resume control, hides the pause menu and unpauses the SceneTree.

The test uses the built-in Godot UI actions mapped from arrow keys, Escape and Space. The corresponding built-in actions also support controller navigation when a gamepad is connected, but this CI test simulates keyboard events only.

Run with the existing boot smoke command:

```sh
godot --headless --path . --verbose --script res://tests/boot_smoke_test.gd
```

Godot 4.7.2 run [44880365084](https://github.com/Legioniz/LatchPoint/actions/runs/44880365084) passed the resource import, tracked-GDScript parse, physics and boot smoke-test workflow with these focus assertions enabled.

Headless CI verifies focus ownership and navigation logic, not the visible focus style, mouse usability, native desktop window behavior, or physical gamepad hardware. Perform those checks manually on supported targets before marking the full menu UX backlog item complete.
