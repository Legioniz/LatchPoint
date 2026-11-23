# Research Register

Checked 2026-11-10. These references establish the first research baseline. Re-check them when a design decision depends on an API or current implementation detail.

## Audio playback shutdown and resource lifetime

### Godot 4.7 — AudioStreamPlayer
- Source: https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer.html
- Relevant behavior: assigning an empty `stream` stops currently playing sounds; `stop()` stops all sounds from the player. The API does not promise that AudioServer-side playback references are released synchronously with the call.
- Project observation: the initial inspected CI run `42573252526` reported retained `AudioStreamPlaybackMP3` and `AudioStreamMP3` references after the physics smoke test but not after boot. Later successful runs `42772371690` and `42772488665` report the same resources after both physics and boot smoke-test processes. The warning persists despite `shutdown_audio()` stopping the player and clearing its stream.

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

## High-speed CharacterBody2D collision regression

### Godot 4.7 — CharacterBody2D movement and collision
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant behavior: CharacterBody2D is code-driven and should move in _physics_process(). move_and_slide() moves along the body's velocity, resolves collisions and adjusts velocity when contact changes the movement.
- Test decision: extend the existing test-only CharacterBody2D probe rather than changing the shipping player controller. At the configured 60 Hz physics rate, the probe travels 100 pixels per tick (6,000 pixels/second) toward a 20-pixel-thick surface. The test repeats the check against floor, wall and ceiling geometry and asserts both the surface classification and non-penetration.
- Interpretation: this is a regression measurement for the project's Godot 4.7.2 configuration and these fixture shapes. It is not a universal guarantee for arbitrary velocities, shapes, collision layers or platforms.

### Godot Demo Projects — Kinematic Character 2D
- Source: https://github.com/godotengine/godot-demo-projects/tree/master/2d/kinematic_character
- License: the Godot demo-project repository declares MIT. It is used only as an official implementation/architecture comparison; no source code, scenes, art or assets are copied.
- Relevance: its CharacterBody2D example keeps movement in the physics callback and uses Godot's collision APIs. The current regression harness follows that engine-level separation by placing the high-speed velocity on a test-only probe.

### Design decision
- This task does not select or alter a LatchPoint gameplay mechanic. Commercial/indie game comparisons are not applicable to this engine-level test-only change.
- No runtime movement values, collision shapes, physics settings or dependencies were changed.
- No external code, art, sound or level content was reused.

## Floor-wall corner collision regression

### Godot 4.7 — CharacterBody2D movement and collision
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant behavior: `move_and_slide()` performs collision response for CharacterBody2D and can produce multiple slide collisions during a movement call. Godot exposes collision count/details and surface classification through the CharacterBody2D API.
- Test decision: use the existing test-only CharacterBody2D probe with a concave corner made from two orthogonal rectangle shapes on one StaticBody2D. Accumulate `is_on_floor()` and `is_on_wall()` observations after each physics movement, then assert both contacts and verify the probe bounds remain outside both surfaces.
- Scope: this validates two deterministic approach orders for this fixture; it is not a general guarantee for arbitrary corner geometry or velocities.

### Godot Foundation — Kinematic Character 2D demo
- Source: https://github.com/godotengine/godot-demo-projects/tree/master/2d/kinematic_character
- License: the official Godot demo-project repository declares MIT. It is a reference for CharacterBody2D platform interactions only; no source code, scenes, art or assets were copied.
- Relevance: the demo demonstrates floor, moving-platform and one-way-platform interactions, supporting the decision to keep physics behavior in the CharacterBody2D physics loop and to add focused collision regressions rather than alter production movement.

### Design decision
- This is an engine-level test-only task. Commercial/indie gameplay comparisons and corner-correction mechanics are not adopted because the core gameplay loop is unconfirmed.
- No shipping movement values, collision geometry, physics settings, assets or dependencies changed.

## Decision rule

The references are inspiration and technical evidence, not a feature checklist. Each adopted pattern must be tied to the LatchPoint design pillars, implemented originally, tested and recorded in the improvement log. No external code, art, sound, level or character is copied by this register.
