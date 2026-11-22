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

## 2026-11-12 — Audio playback shutdown and mix-cycle synchronization

### Godot 4.7 — AudioStreamPlayer
- Source: https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer.html
- Relevant behavior: assigning an empty `stream` stops all currently playing sounds; `has_stream_playback()` reports whether a sound is still active. These player-side checks do not by themselves prove that the AudioServer has released its playback-list reference.
- Project decision: after calling the existing Audio autoload shutdown method, assert that the player is stopped, has no active playback and has no stream assigned.

### Godot 4.7 — AudioServer timing API
- Source: https://docs.godotengine.org/en/4.7/classes/class_audioserver.html
- Relevant behavior: `get_time_since_last_mix()` reports the time since the previous audio mix, while `get_time_to_next_mix()` estimates the time until the next mix. Audio mixing does not occur once per rendered/process frame.
- Project decision: replace the arbitrary two-frame-only wait in the physics smoke test with a bounded observation of an actual mix-age reset (maximum 120 process frames), then allow two further process frames for main-thread cleanup. The test logs the active driver, mix rate, initial next-mix estimate and number of process frames waited. A timeout is a test failure, not a reason to suppress the engine warning.

### Godot 4.7-stable — AudioServer playback lifecycle
- Sources: https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_server.cpp#L1289-L1319, https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_server.cpp#L534-L540, https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_server.cpp#L734-L742, and https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_server.cpp#L1626-L1638
- Relevant implementation: stopping a non-sample playback marks its list node for fade-out/deletion; the audio mix step removes it, and the list's destructor is deferred for main-thread cleanup. This supports the hypothesis that a test can exit before a mix and cleanup cycle has completed. It does not prove the hypothesis until the updated CI log is checked.
- License: Godot Engine source is MIT licensed. Source was inspected for lifecycle behavior only; no engine code was copied.

### Godot 4.7-stable — Dummy audio driver
- Source: https://github.com/godotengine/godot/blob/4.7-stable/servers/audio/audio_driver_dummy.cpp#L56-L72
- Relevant implementation: the dummy driver processes audio on its own thread and delays between buffers according to `buffer_frames / mix_rate`. Godot's headless mode selects the Dummy driver; see https://docs.godotengine.org/en/4.7/classes/class_audioserver.html#class-audioserver-method-get-driver-name.
- Project implication: process-frame waits and audio-mix timing are separate clocks. The previous two-process-frame wait did not guarantee that the dummy driver's next mix had run before process exit.

### Scope and licensing
- This is a test-harness lifecycle correction only. No production audio behavior, game mechanic, asset or dependency is changed.
- No commercial/indie mechanic is relevant to this engine-lifecycle objective. No external code or assets are reused.


### Additional process coverage — boot smoke test
- Evidence: workflow run [43170846659](https://github.com/Legioniz/LatchPoint/actions/runs/43170846659) showed the physics smoke test's mix-cycle cleanup passing, followed by the boot smoke-test process reporting retained MP3/ObjectDB references at exit.
- Finding: each CI smoke-test command is a separate Godot process with its own Audio autoload and AudioServer playback lifecycle. Cleanup performed in one process cannot satisfy the next process's shutdown contract.
- Project decision: apply the same player stopped/empty assertions, bounded observed mix-age reset and deferred main-thread cleanup wait in `tests/boot_smoke_test.gd`. Verify cleanup on early failure paths as well as successful completion. Keep the production Audio autoload unchanged.
- Verification: Godot 4.7.2 run [43174879566](https://github.com/Legioniz/LatchPoint/actions/runs/43174879566) observed the physics-test mix reset after 10 process frames and the boot-test reset after 2 process frames, both using the Dummy driver at 44,100 Hz. No retained MP3/ObjectDB warnings or errors followed either smoke-test process.


## 2026-11-18 — Shared smoke-test audio shutdown verifier

### Godot 4.7 — AudioServer
- Source: https://docs.godotengine.org/en/4.7/classes/class_audioserver.html
- Relevant behavior: `get_time_since_last_mix()` reports the relative time since the last mix, and `get_time_to_next_mix()` reports the relative time until the next mix. These are AudioServer timing observations, not process-frame counters.
- Design decision: retain the existing bounded 120-process-frame observation of a mix-age reset and preserve the two additional process frames for deferred main-thread cleanup.

### Godot 4.7 — SceneTree
- Source: https://docs.godotengine.org/en/4.7/classes/class_scenetree.html
- Relevant behavior: `process_frame` is emitted immediately before Node `_process()` callbacks. Awaiting this signal advances the smoke-test coroutine by one process frame.
- Design decision: pass the active SceneTree into a shared test helper so both standalone SceneTree scripts use the same wait implementation without creating a node or changing runtime scene ownership.

### Godot 4.7 — GDScript coroutines
- Source: https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
- Relevant behavior: `await` can suspend a function on a signal or another coroutine and resume when it completes.
- Design decision: keep the verifier as a test-only RefCounted helper and await its result from each smoke-test entrypoint. Do not make the helper an autoload or production audio dependency.

### Project-specific decision and scope
- Both smoke tests previously duplicated the player shutdown assertions, 120-frame mix-reset loop, diagnostic fields and two-frame deferred cleanup.
- Consolidate that shared lifecycle contract in `tests/audio_shutdown_verifier.gd`; keep each smoke-test invocation independent because each CI command launches a separate Godot process.
- Preserve the existing difference in preconditions: the physics smoke test requires that background music actually started; the boot smoke test only requires that the Audio autoload can be shut down cleanly.
- The helper returns structured errors and diagnostic data; callers continue to report failures using their existing failure/exit paths.
- No production audio behavior, scenes, assets, bus configuration, project settings, gameplay behavior or third-party dependencies are changed.
- Official Godot documentation is used as a technical reference; no source code or assets are copied. No commercial/indie gameplay mechanic is applicable to this test-infrastructure refactor.

## 2026-11-19 — Debounced settings persistence and exit-tree flush

### Godot 4.7 — Timer
- Source: https://docs.godotengine.org/en/4.7/classes/class_timer.html
- Relevant behavior: a Timer starts only after entering the SceneTree, emits timeout after its wait time, and is affected by Engine.time_scale.
- Design decision: attach the isolated Settings fixture to the active SceneTree so its ready callback creates and starts the actual debounce Timer. Assert the Timer is pending and the settings file is absent before allowing another frame to process.

### Godot 4.7 — Node lifecycle
- Source: https://docs.godotengine.org/en/4.7/classes/class_node.html
- Relevant behavior: the exit-tree callback is called when a node is about to leave the SceneTree, including when it is freed; a parent exits after its children.
- Design decision: free the in-tree test fixture immediately after changing a preference. This exercises the production exit-tree callback while the debounce Timer is still pending, without waiting for wall-clock time.

### Godot 4.7 — ConfigFile
- Source: https://docs.godotengine.org/en/4.7/classes/class_configfile.html
- Relevant behavior: ConfigFile stores Variant values and changes remain in memory until save() writes them to the selected path.
- Design decision: reload the isolated user://latchpoint_settings_smoke_test.cfg after fixture teardown and assert that the last debounced value survived the exit-tree flush.

### Scope and licensing
- Official Godot documentation is used as API/lifecycle reference only.
- No external source code, commercial game code, art, audio, levels or assets were copied.
- This is test-infrastructure coverage; production settings behavior and architecture are unchanged.


## 2026-11-20 — Reconcile settings lifecycle and audio shutdown test branches

### Official Godot 4.7 — AudioServer
- Source: https://docs.godotengine.org/en/4.7/classes/class_audioserver.html
- Relevant behavior: `get_time_since_last_mix()` reports the relative time since the last audio mix; `get_time_to_next_mix()` reports the relative time until the next mix. `get_driver_name()` identifies the active driver, and headless mode uses the Dummy driver.
- Design decision: after stopping and clearing the player, wait for an observed mix-age reset rather than assuming a fixed number of SceneTree frames is sufficient.

### Official Godot 4.7 — SceneTree
- Source: https://docs.godotengine.org/en/4.7/classes/class_scenetree.html
- Relevant behavior: `process_frame` is emitted immediately before Node `_process()` callbacks.
- Design decision: retain the existing bounded 120-process-frame observation and two additional process frames for deferred cleanup. Keep each smoke-test process independent.

### Cross-branch evidence and decision
- PR #15's Godot 4.7.2 run [44478777582](https://github.com/Legioniz/LatchPoint/actions/runs/44478777582) completed, but its physics process emitted ObjectDB, MP3 playback/resource and StringName retention diagnostics after using only a fixed two-frame wait. Its boot process did not emit the same diagnostics.
- PR #14's Godot 4.7.2 run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262) observed a mix-age reset in both processes and emitted no matching retention diagnostics.
- Both branches use the same production `AUDIO.gd` blob (`bbfc914556569a979a71c3a313cb4fbb97829509`). This points toward a test-harness synchronization difference, but does not by itself prove the complete root cause.
- Integration decision: combine PR #14's shared verifier with PR #15's settings lifecycle test. Keep production audio/settings scripts unchanged and verify the combined tree in one fresh Godot 4.7.2 run.

### Scope and licensing
- Official Godot 4.7 documentation is used as API reference. Existing project-owned test code is being integrated; no external source code, audio, art, levels or characters are copied.
- Commercial/indie gameplay comparisons are not applicable to this engine-lifecycle and test-integration objective.


### Combined integration verification — 2026-11-20
- Godot 4.7.2 run [44689407205](https://github.com/Legioniz/LatchPoint/actions/runs/44689407205) passed on the combined branch. Physics observed the Dummy-driver mix reset after 7 process frames (44,100 Hz; initial next-mix estimate 0.0432 s); boot observed it after 9 frames (44,100 Hz; initial estimate 0.0612 s).
- The complete verbose job log contained no retained ObjectDB, MP3 playback/resource, or StringName diagnostics after either process. This supports the test-harness synchronization hypothesis but does not establish every internal ownership detail.
- The Node.js 20 deprecation notice from actions/checkout@v4 is a separate CI maintenance warning tracked by PR #11.


## 2026-11-21 — Keyboard/controller focus and menu navigation

### Official Godot 4.7 — Keyboard/Controller Navigation and Focus
- Source: https://docs.godotengine.org/en/4.7/tutorials/ui/gui_navigation.html
- Relevant findings: built-in `ui_up`, `ui_down`, `ui_focus_next` and related actions drive Control focus navigation; focus neighbors define directional navigation; a control can lose focus when hidden; initial focus should be assigned with `Control.grab_focus()`, deferred until the scene is ready.
- Design decisions: assign initial focus with `grab_focus.call_deferred()`; define explicit vertical neighbors for the current vertically arranged controls; do not repurpose UI navigation actions for gameplay input.

### Official Godot 4.7 — Control
- Source: https://docs.godotengine.org/en/4.7/classes/class_control.html
- Relevant findings: only one Control owns GUI focus at a time; `grab_focus()` transfers focus; `FOCUS_ALL` permits keyboard/controller navigation while `FOCUS_NONE` prevents focusing; focus neighbors can be configured through NodePaths.
- Design decisions: change the pause menu's three buttons from explicit `FOCUS_NONE` to `FOCUS_ALL`; focus Resume whenever the pause overlay opens; release pause-menu focus when it closes; keep the unavailable Load button disabled and non-focusable.

### Open-source reference — Godot Demo Projects UI Accessibility
- Source: https://github.com/godotengine/godot-demo-projects/tree/master/gui/accessibility
- License: repository `LICENSE.md` declares MIT; the sample is an official GDScript UI-accessibility demonstration.
- Finding: the project provides a maintained Godot 4.7 reference for accessible UI controls and focus-aware interfaces.
- Use: architectural/reference inspection only. No source code, scenes, text, icons, fonts or other assets were copied.

### Scope and design decision
- The current task is a bounded usability fix for the existing menu flow, not a new gameplay mechanic. Commercial/indie game comparisons are not applicable to this generic engine UI-focus correction.
- Keep the existing scene composition and visual layout. Add initial focus and explicit vertical focus neighbors only; defer responsive-layout redesign and native gamepad testing.
- Add deterministic boot-smoke assertions by dispatching keyboard events through the viewport. Headless input simulation does not replace physical keyboard/gamepad or native desktop visual verification.
- No new dependencies, input actions, runtime autoloads, gameplay behavior, assets or third-party code are introduced.


## 2026-11-22 — Default gamepad confirm/cancel actions

### Official Godot 4.7 — InputEventJoypadButton
- Source: https://docs.godotengine.org/en/4.7/classes/class_inputeventjoypadbutton.html
- Relevant behavior: `InputEventJoypadButton` represents a gamepad button press or release and exposes a standardized JoyButton index.
- Design decision: use Godot's standardized `JOY_BUTTON_A` and `JOY_BUTTON_B` identifiers instead of platform-specific raw button numbers.

### Official Godot 4.7 — Controllers, gamepads and joysticks
- Source: https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html
- Relevant behavior: use InputMap actions for universal input and account for controller-specific mapping behavior. D-pad and analog-stick navigation can share UI actions.
- Design decision: keep menu navigation on the existing built-in `ui_up`/`ui_down` actions and add only the missing confirm/cancel bindings.

### Godot 4.7-stable engine InputMap defaults
- Source: https://github.com/godotengine/godot/blob/4.7-stable/core/input/input_map.cpp
- Relevant findings: the 4.7-stable built-in `ui_accept` defaults are Enter, keypad Enter and Space; `ui_cancel` defaults to Escape. Built-in `ui_up`/`ui_down` include keyboard arrows, D-pad buttons and left-stick Y-axis events. Therefore the existing focus navigation could move with a controller, but standard Joypad A/B were not configured to activate/cancel focused UI.
- License: Godot engine source is MIT-licensed; source was inspected as an implementation reference only. No engine code was copied.

### Scope, compatibility and design decision
- Add an all-device Joypad A event to `ui_accept` and Joypad B to `ui_cancel` through a dedicated `UIInput.gd` autoload that initializes before the main scene.
- Preserve all existing action events and avoid duplicate global-device mappings. Do not override the existing D-pad/analog navigation mappings.
- Test with synthetic `InputEventJoypadButton` events in the boot smoke test. This verifies InputMap and focused-Control behavior but is not a substitute for a physical controller test.
- This is a generic UI input mapping correction; commercial/indie gameplay comparisons are not applicable. No third-party code, assets, levels, characters, audio or text are reused.
