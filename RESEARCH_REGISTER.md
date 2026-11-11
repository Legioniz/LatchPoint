# Research Register

Checked 2026-11-10. These references establish the first research baseline. Re-check them when a design decision depends on an API or current implementation detail.

## Settings persistence and user-data storage

### Godot 4.7 — ConfigFile
- Source: https://docs.godotengine.org/en/4.7/classes/class_configfile.html
- Relevant behavior: ConfigFile stores Variant values by section/key in an INI-style file. Mutating the in-memory ConfigFile does not write it to disk; `save()` must be called explicitly. `get_value()` supports defaults for missing keys.
- Project decision: use ConfigFile for small per-install preferences, validate loaded types and numeric ranges, and keep these preferences separate from future gameplay save slots.

### Godot 4.7 — Persistent user-data paths
- Source: https://docs.godotengine.org/en/4.7/tutorials/io/data_paths.html
- Relevant behavior: `user://` is created automatically and is writable in exported projects; `res://` is the project resource path and may be read-only at runtime.
- Project decision: write preferences to `user://settings.cfg`, never into the project resource tree.

### Settings Menu Lite — open-source Godot 4 settings example
- Source: https://github.com/godot-forge/settings-menu-lite-godot
- Scale: small independent Godot 4 settings utility with an autoload, an options panel and ConfigFile persistence.
- Observed principle: centralize settings ownership, apply values through engine APIs, and load preferences before scenes need them.
- License: repository declares MIT. The license was inspected on 2026-11-10. Used as an architectural reference only; no code, scenes, UI, icons or other assets were copied.

### Saltmire — ConfigFile settings implementation article
- Source: https://dev.to/saltmire/how-to-save-game-settings-volume-fullscreen-keybinds-in-godot-4-with-configfile-abp
- Relevant observation: keep per-machine preferences in `user://settings.cfg`, apply settings separately from loading them, and avoid writing to disk on every slider value change.
- Project decision: apply volume changes immediately, then debounce ConfigFile writes for 0.5 seconds and flush pending changes when the Settings autoload exits. No article code was copied.

## Audio playback shutdown and resource lifetime

### Godot 4.7 — AudioStreamPlayer
- Source: https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer.html
- Relevant behavior: assigning an empty `stream` stops currently playing sounds; `stop()` stops all sounds from the player. The API does not promise that AudioServer-side playback references are released synchronously with the call.
- Project observation: the initial inspected CI run `42573252526` reported retained `AudioStreamPlaybackMP3` and `AudioStreamMP3` references after the physics smoke test but not after boot. Later successful runs `42772371690` and `42772488665` report the same resources after both physics and boot smoke-test processes. The warning persists despite `shutdown_audio()` stopping the player and clearing its stream. The 2026-11-10 settings branch CI run `42775181753` also reports two ObjectDB instances and one `AudioStreamMP3` resource at shutdown after both smoke-test processes; after freeing isolated settings-test nodes, no Settings.gd resource leak or out-of-tree Node-path errors remain. The remaining MP3 warning is tracked separately by issue #3.

### Godot 4.7-stable — AudioStreamPlayerInternal and AudioServer implementation
- Sources: https://github.com/godotengine/godot/blob/4.7-stable/scene/audio/audio_stream_player_internal.cpp and https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_server.cpp
- Relevant implementation: `AudioStreamPlayerInternal::stop_basic()` asks the AudioServer to stop each playback and clears the player's local playback references. `AudioServer::stop_playback_stream()` marks the server playback node for fade-out/deletion; the audio mix path removes it.
- Investigation implication: test shutdown may be racing asynchronous server cleanup, but source inspection alone does not prove that this is the cause of LatchPoint's warning. A repeatable CI experiment is required before changing production code.

### Related upstream report — Godot issue #76745
- Source: https://github.com/godotengine/godot/issues/76745
- Context: an older Godot 4.0.2 report describes audio playback resources retained at process exit. It is a related symptom only; it is not evidence that LatchPoint has the same root cause or that the issue persists unchanged in Godot 4.7.

### Project decision
- Track the warning in https://github.com/Legioniz/LatchPoint/issues/3.
- Do not silence the warning, remove audio from tests, or weaken physics assertions. Establish a reproducible fix or a verified engine limitation first.
- No external code, music, or assets reused.

## Window and display behavior

### Godot DisplayServer — window mode and borderless flag
- Source: https://docs.godotengine.org/en/latest/classes/class_displayserver.html
- Relevant behavior: entering fullscreen forces the borderless flag to true; applications that want normal window decorations must explicitly set the flag back to false when returning to windowed mode. Borderless removes native title-bar/window decorations and is ignored while fullscreen.
- Project decision: default LatchPoint to a decorated window and synchronize the fullscreen toggle with both `Window.mode` and `Window.borderless`. The toggle must not leave the app borderless after returning to windowed mode.
- No external code or assets reused.

## Game-feel and player-control references

### Celeste — Maddy Thorson, developer-authored notes
- Source: https://www.maddymakesgames.com/articles/celeste_and_forgiveness/
- Scale: major commercial precision platformer.
- Observed design principles: coyote time, jump buffering, reduced gravity near the jump apex while jump is held, and corner correction are used to make platforming feel more forgiving and controllable.
- Potential LatchPoint application: evaluate input forgiveness only after the intended jump/interaction loop is defined. Measure whether it improves control without undermining challenge.
- Do not copy proprietary implementation or claim that every technique belongs in LatchPoint by default.

### Flick! — open-source Godot 4.x 2D platformer
- Source: https://github.com/codernunk/flick
- Scale: small independent/open-source game.
- Observed design principle: the game's identity is built around a distinct directional-launch ability. Its project also separates scenes and documents code/art licenses.
- Potential LatchPoint application: make one clear mechanic central to the player's decisions; keep reusable character/world elements modular.
- License note: the repository describes MIT-licensed source code and CC-BY-4.0 assets. Inspect the exact asset and attribution terms before reuse. No Flick code or assets are imported by this project.

### Joey's Slimeventure — open-source Godot 4.7 platformer
- Source: https://github.com/PondSec/JoeysSlimeventure
- Scale: actively developed independent game.
- Observed design principles: handcrafted pixel art is combined with procedural cave generation; public development separates stable `main` from an active development branch; the project emphasizes testable, documented PRs.
- Potential LatchPoint application: separate experimental development from stable releases and use procedural systems only when they improve replayability without making levels feel arbitrary.
- No code or assets are imported by this project.

### Out Of Reach — small game-jam puzzle platformer
- Source/devlog: https://bulldozerdev.itch.io/out-of-reach/devlog/1742901/out-of-reach-is-now-open-source
- Date noted by source: 2026-10-31.
- Scale: University of Waterloo Spring 2026 game-jam prototype.
- Observed design principle: a simple spatial rule (platforms moving away from the player) and gravity zones can carry a compact puzzle-platforming idea.
- Potential LatchPoint application: prototype one mechanic in a small playable level before expanding content. Verify license and project terms before reuse.
- This is a design reference only; no source or asset reuse is implied.

## Engine, physics and test references

### Godot 4.7 — CharacterBody2D movement and collision
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant points: `CharacterBody2D` is manually controlled; movement belongs in `_physics_process`; `move_and_slide()` is appropriate for many platformer situations; `move_and_collide()` returns collision information for custom responses; slide collisions can be inspected after movement.
- Project application: use physics APIs with a deliberate response model and test collision cases in the running project.

### Godot 4.7 — Input action simulation
- Source: https://docs.godotengine.org/en/4.7/classes/class_input.html
- Relevant points: `Input.action_press()` and `Input.action_release()` simulate Input Map actions; the documentation says these methods are intended to work with `is_action_pressed()` and `is_action_just_pressed()`, but do not invoke `Node._input()`.
- Project application: the current player controller reads the global Input state directly in `_physics_process()`, so the smoke test can drive the real controller without hardware input or a second input abstraction.

### Godot 4.7 — deterministic physics callback ordering
- Sources: https://docs.godotengine.org/en/4.7/classes/class_node.html and https://docs.godotengine.org/en/4.7/classes/class_scenetree.html
- Relevant points: `Node._physics_process()` runs once per physics tick; its `delta` is based on `Engine.time_scale / Engine.physics_ticks_per_second`. Lower `process_physics_priority` values run first. The SceneTree `physics_frame` signal itself is emitted before node physics callbacks.
- Project application: the smoke test uses a test-only physics waiter at priority 100 to count exact ticks after the player's default-priority controller callback. CI showed that elapsed-time and signal-await helpers could each include an extra step in this harness, so assertions now wait for the explicit counter signal before reading velocity.

### Godot Demo Projects — 2D platformer and kinematic character
- Source: https://github.com/godotengine/godot-demo-projects
- Scale: official open-source Godot demonstration projects, including Godot 4.7-compatible 2D platformer examples written in GDScript.
- Observed principle: platformer controllers should keep movement and collision responses in the physics loop; the examples provide a useful comparison for acceleration, stopping, jump and platform interactions.
- License: the demo-project repository is MIT licensed. It is used as a design/technical reference only; no source code, art, audio or levels are copied.

### Godot command-line validation
- Source: https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html
- Relevant points: headless import and command-line execution can be used in CI; `--import` performs project resource import; headless runs can execute scripts and projects without opening a game window.
- Project application: the initial GitHub Actions workflow imports the project and runs deterministic scene, physics and player-movement smoke checks.

### GdUnit4
- Source: https://godot-gdunit-labs.github.io/gdUnit4/latest/
- Relevant points: supports Godot 4.x GDScript/C# unit and scene testing, test discovery, parameterized/fuzz testing, scene input simulation and CI reports.
- Project application: evaluate it when the test suite expands. A lightweight built-in harness is used first to avoid adding a framework before its value is proven.

### Godot setup action for CI
- Source: https://github.com/chickensoft-games/setup-godot
- Relevant points: installs Godot 4.x on GitHub Actions Linux/macOS/Windows runners and supports standard builds without .NET.
- Project application: install Godot 4.7.2 in the repository validation workflow.

## Collision layer and mask regression coverage

### Godot 4.7 — CollisionObject2D
- Source: https://docs.godotengine.org/en/4.7/classes/class_collisionobject2d.html
- Relevant behavior: a collision layer describes which 2D physics layers an object occupies; a collision mask describes which layers it scans. Godot supports 32 2D physics layers. A body detects another body when the other body's layer overlaps the querying body's mask.
- Project decision: inspect the instantiated gameplay player and each enabled static platform. Require a non-zero platform layer and a bitwise overlap between `player.collision_mask` and `platform.collision_layer`. Do not require a reciprocal platform mask: the CharacterBody2D player is the querying body for this collision contract.

### Godot 4.7 — Using CharacterBody2D
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant behavior: CharacterBody2D movement and collision response should be driven from physics processing using `move_and_slide()` or `move_and_collide()`; the former is intended for common sliding movement and exposes collision results.
- Project decision: leave the shipping player controller unchanged. Validate the actual scene's collision configuration alongside the existing real-player floor-landing test.

### Godot demo projects — Kinematic Character 2D
- Source: https://github.com/godotengine/godot-demo-projects/tree/master/2d/kinematic_character
- Relevant example: the sample uses a GDScript CharacterBody2D controller with `move_and_slide()`; its README describes moving-platform and one-way-platform behavior as additional platformer cases.
- License: the repository's LICENSE.md declares MIT. Reviewed on 2026-11-11. This is an architectural/test-scope reference only; no code, scenes, art, audio or other assets were copied.
- Project decision: use the sample to identify future coverage candidates, not to add moving or one-way platforms to LatchPoint before those mechanics are part of the confirmed design.

### GDSense — CharacterBody2D player movement
- Source: https://gdsense.com/docs/guides/characterbody2d-player-movement
- Relevant observation: the secondary guide recommends checking that the player mask includes the floor layer when diagnosing missed platform collisions.
- Status: non-normative technical reading; official Godot documentation remains authoritative. No code was copied.

### Design-scope note
No commercial or indie gameplay mechanic is being adopted in this test-only cycle. The core loop remains unconfirmed, and this change does not alter player-facing behavior.

## Decision rule

The references are inspiration and technical evidence, not a feature checklist. Each adopted pattern must be tied to the LatchPoint design pillars, implemented originally, tested and recorded in the improvement log. No external code, art, sound, level or character is copied by this register.
