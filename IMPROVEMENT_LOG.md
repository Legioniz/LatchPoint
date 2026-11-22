# Improvement Log

Each completed cycle records its purpose, affected files, sources, verification evidence, remaining risks and PR/commit link. Unrun tests are explicitly marked as unverified.

## 2026-11-10 — Persistent audio and fullscreen preferences

**Objective:** implement the existing backlog item for options persistence without changing the unconfirmed gameplay direction.

- Added `Settings.gd` as a small autoload that owns the user settings file, defaults, validation and persistence.
- Stored Master, Music and SFX bus levels as linear values plus the fullscreen preference in `user://settings.cfg`. The settings file is separate from future gameplay save slots.
- Registered Settings before Audio so the Audio autoload can load saved bus values before applying them to AudioServer.
- Routed fullscreen changes through Settings so the stored preference is applied at startup and when the Options screen is opened or toggled.
- Debounced disk writes by 0.5 seconds while a slider is moving and flush pending changes when the Settings autoload exits.
- Extended the boot smoke test to cover first-run defaults, save/reload round trips, invalid-value recovery, Music bus synchronization and window-decoration restoration.
- The test uses a dedicated temporary settings file and removes it after the assertions; it does not overwrite the player's real preferences.
- No game-progress save/load, new gameplay mechanic, third-party dependency, code, music or asset was added.

**Verification**
- Local Godot execution: not run; no Godot executable is installed in this environment.
- Godot 4.7.2 GitHub Actions validation: passed on 2026-11-10 in run [42775181753](https://github.com/Legioniz/LatchPoint/actions/runs/42775181753): resource import, every tracked GDScript parse check, physics smoke test, and boot/settings persistence test all completed successfully.
- Manual desktop fullscreen/restart verification: pending; headless tests cannot verify native title-bar behavior on a real desktop.
- Performance: no runtime profiler was available. The 0.5-second debounce is a write-frequency safeguard, not a measured performance improvement.
- The same CI logs still report two ObjectDB instances and one `AudioStreamMP3` resource retained at shutdown for `res://Project_bullshit.mp3` after both smoke-test processes. This remains the separate, unresolved issue [#3](https://github.com/Legioniz/LatchPoint/issues/3); no Settings.gd resource leak or out-of-tree Node-path errors remained after the test fixtures were explicitly freed.
- ML: not used.

**Research:** Godot 4.7 ConfigFile and user-data-path documentation; MIT-licensed Godot Settings Menu Lite as an open-source architectural comparison; a Godot ConfigFile settings tutorial. See `RESEARCH_REGISTER.md`.

**Branch:** `feature/settings-persistence`, based on `feature/player-movement-regression-tests`. **Commits:** `79247183725cc22cca3796e663d91aa58c892ee3` (feature), `0986d559cfafdbb3de88fb129dbc7ea8dafb6444` (fixture cleanup), `c2cfa17107f26884556239cbc0cc2dff26953fe8` (verification docs), and `91fcf91369e1751ac2a2cd08ce2ac2e9ccaf6240` (isolated audio integration fixture), and `8e7019ae8f5aca4e6dcc79198c713f0bd8cb419b` (final verification record).

## 2026-11-10 — Player movement regression coverage

**Objective:** establish a deterministic regression baseline for the existing CharacterBody2D controller without changing the unconfirmed game design.

- Extended `tests/physics_smoke_test.gd` to instantiate the actual `res://Scene/player.tscn` against a temporary static floor fixture.
- Simulated the existing `ui_right` and `ui_accept` actions with Godot's Input singleton and synchronized assertions to completed physics callbacks.
- The first CI attempt exposed a one-tick overrun in a timer-based wait (180 px/s observed versus 150 px/s expected at 60 Hz). A second attempt using the `physics_frame` signal retained the same off-by-one because that signal fires before node callbacks. The final helper is a persistent test-only physics waiter at physics priority 100; it counts exact ticks after the player's default-priority callback and is reused between assertions to avoid creating a new frame boundary.
- Added assertions for configured horizontal acceleration, friction after release, grounded jump velocity, gravity increasing vertical velocity, and rejection of a second jump while airborne.
- Kept the existing scene-load, floor-landing, and floor/wall/ceiling probe checks intact.
- No shipping gameplay script, scene, asset, project setting, input map, or dependency was changed. The test fixture is transient and exists only in the smoke-test process.
- This completes the current-player-movement baseline slice of the broader deterministic physics QA task; corners, slopes, one-way/moving platforms, tunneling, masks, and respawn overlap remain open.

**Verification**
- Local Godot execution: not run; no Godot executable is installed in this environment.
- Godot 4.7.2 GitHub Actions validation: pending the feature-branch push.
- Manual in-game feel/visual testing: not performed. The core gameplay loop and design pillars remain unconfirmed.
- Performance: no runtime profiling performed because this is test-only code and no runtime optimization was made.
- ML: not used; deterministic input simulation is ordinary scripted testing, not machine learning.

**Status:** persistent waiter correction committed after two CI runs exposed frame-boundary over-counting; final CI validation is pending.

**Research:** Godot 4.7 CharacterBody2D, Input, and SceneTree documentation; Godot demo-project platformer and Celeste developer notes. See `RESEARCH_REGISTER.md`.

**Branch:** `feature/player-movement-regression-tests` (dependent on the open foundation/window/audio documentation PR chain).

## 2026-11-11 — Player/platform collision-layer contract

**Objective:** add one bounded, deterministic regression check for the current gameplay scene's collision-layer configuration without changing the unconfirmed game loop.

- Extended `tests/physics_smoke_test.gd` to inspect the real gameplay scene's enabled `StaticBody2D` platforms.
- Each enabled platform must have a non-zero collision layer, and at least one of its layer bits must be included in the instantiated player's collision mask.
- Error messages identify the platform, player mask and platform layer to make configuration failures actionable.
- Kept the existing real-player landing check and generic floor/wall/ceiling probes intact.
- No runtime controller, scene, collision geometry, collision layer/mask setting, asset or dependency was changed.
- Updated the backlog, research register and testing guide. No architecture document change was needed because runtime responsibilities and scene composition are unchanged.

**Acceptance criteria**
- The actual gameplay player is instantiated from `res://Scene/main.tscn`.
- Every enabled static platform has a valid shape, a non-zero collision layer and a layer bit scanned by the player.
- Existing movement and collision assertions remain enabled and unchanged.

**Verification**
- Local Godot execution: not run; no Godot executable is installed in this environment.
- GitHub Actions: passed on 2026-11-11 in [run 42978084594](https://github.com/Legioniz/LatchPoint/actions/runs/42978084594) using Godot 4.7.2. Resource import, every tracked GDScript parse check, the physics smoke test and the boot/settings test all completed successfully. The physics output confirms the platform-layer/player-mask contract and the existing movement and floor/wall/ceiling assertions.
- The verbose log still reports two ObjectDB instances and one retained `AudioStreamMP3`/`AudioStreamPlaybackMP3` reference for `res://Project_bullshit.mp3` after both smoke-test processes. This remains the separate unresolved [issue #3](https://github.com/Legioniz/LatchPoint/issues/3); no warning was suppressed and no test was weakened.
- Existing baseline run [42775603750](https://github.com/Legioniz/LatchPoint/actions/runs/42775603750) passed import, GDScript parsing, physics smoke tests and boot tests on the parent branch. Its verbose log still reports the separate unresolved MP3/ObjectDB shutdown warning tracked by [issue #3](https://github.com/Legioniz/LatchPoint/issues/3).
- Manual in-game verification: not performed.
- Physics: this is a configuration assertion plus the existing automated floor/wall/ceiling tests; no new geometry or physics response was introduced.
- Performance: no runtime code changed and no profiler measurement was available.
- ML: not used; these are deterministic assertions, not machine learning.

**Research:** Godot 4.7 CollisionObject2D and CharacterBody2D documentation; the MIT-licensed Godot demo-project Kinematic Character sample; a secondary CharacterBody2D technical guide. See `RESEARCH_REGISTER.md`.

**Branch:** `feature/physics-layer-mask-regressions`, based on `feature/settings-persistence`. **Implementation commit:** `44243da11c612df07cf8a9871f80f82a6e9b7bad`.

## 2026-11-12 — Synchronize audio-test shutdown with the AudioServer mix cycle

**Objective:** investigate the retained `AudioStreamMP3` / `AudioStreamPlaybackMP3` references reported after the physics smoke test (issue #3) without changing runtime audio behavior.

- Re-inspected the latest repository branches and PR chain. The existing `fix/audio-shutdown-grace-experiment` branch contains documentation-only changes; no existing code fix was duplicated.
- The latest inspected CI run [42978273469](https://github.com/Legioniz/LatchPoint/actions/runs/42978273469) passed, but its verbose log still reported two ObjectDB instances and one retained `AudioStreamMP3` / `AudioStreamPlaybackMP3` for `res://Project_bullshit.mp3` after the physics test. The following boot test did not show the same warning in that run.
- Godot 4.7 documentation and engine source show that stopping playback marks its AudioServer list node for deletion; actual list removal occurs during an audio mix, with list cleanup deferred to the main thread. Headless mode uses the Dummy audio driver, whose mix cadence is independent of process frames.
- Replaced the physics smoke test's two-process-frame-only shutdown wait with player-side stopped/empty assertions, a bounded observation of an AudioServer mix-age reset (120-frame maximum), and two additional process frames for deferred cleanup. The test records the driver, mix rate, initial next-mix estimate and frames waited.
- No production audio script, scene, asset, audio bus, project setting or gameplay behavior was changed.

**Acceptance criteria**
- The background music player must report no active playback and no assigned stream after shutdown.
- The test must observe a completed AudioServer mix cycle within the bounded wait.
- The subsequent verbose CI log must be checked for retained MP3/ObjectDB warnings; a green exit code alone is insufficient.

**Verification**
- Local Godot execution: not available in this environment.
- GitHub Actions run [43170390237](https://github.com/Legioniz/LatchPoint/actions/runs/43170390237) passed import, GDScript parsing, physics smoke tests and boot tests, and the MP3/ObjectDB warnings were absent. Its verbose output exposed a formatting error in the new diagnostic print; that logging-only defect was corrected in commit `4e2fc4db38adbe0b1d141a841af2894b3bb9631f`.
- Final Godot 4.7.2 validation run [43170548756](https://github.com/Legioniz/LatchPoint/actions/runs/43170548756) passed all import, parser, physics smoke-test and boot-test steps. The diagnostic measured `driver=Dummy`, `mix_rate=44100 Hz`, `initial_next_mix=0.0645s`, and an observed mix reset after 10 process frames. The complete relevant log contained no retained MP3/ObjectDB warnings and no `ERROR` or `WARNING` lines after either smoke-test process.
- This confirms the warning was caused by the test exiting before the asynchronous audio mix/deferred cleanup cycle had completed; the test now waits for that cycle rather than an arbitrary two process frames.
- Manual desktop audio verification: not performed.
- Performance profiling: not performed; this is test-only code.
- Physics/collision behavior: unchanged; existing physics assertions remain enabled.
- ML: not used.

**Research:** Godot 4.7 AudioStreamPlayer and AudioServer documentation; Godot 4.7-stable AudioServer and Dummy audio-driver source. See `RESEARCH_REGISTER.md`.

**Status:** the physics smoke-test process was verified clean; a later full-workflow run exposed a separate boot-test shutdown gap, corrected in the follow-up entry below.

**Branch:** `fix/audio-mix-cycle-shutdown`, based on `feature/physics-layer-mask-regressions`. **Commits:** `c35b7f5aa10fee6eea9f555b0265cb5f0317813c` (mix-cycle wait and research), `4e2fc4db38adbe0b1d141a841af2894b3bb9631f` (diagnostic formatting).


## 2026-11-12 — Extend audio shutdown verification to the boot smoke test

**Objective:** complete issue #3 coverage across both independent Godot smoke-test processes without changing production audio behavior.

- Reviewed the latest workflow run [43170846659](https://github.com/Legioniz/LatchPoint/actions/runs/43170846659), including its full job log. The physics smoke test observed the Dummy driver's mix cycle and exited without the earlier MP3/ObjectDB warning, but the subsequent boot smoke-test process still reported two ObjectDB instances and retained `AudioStreamMP3` / `AudioStreamPlaybackMP3` for `res://Project_bullshit.mp3`.
- Root cause of the remaining test gap: `tests/boot_smoke_test.gd` still stopped the Audio autoload and waited only two process frames. Each smoke-test command runs in its own Godot process, so the physics test's successful shutdown wait cannot clean up the boot test's independent playback.
- Extended the boot test to stop and clear the player, assert that it is inactive and stream-free, observe a bounded `AudioServer.get_time_since_last_mix()` reset (120 process frames maximum), and allow two further process frames for deferred main-thread cleanup.
- Applied cleanup on early failure exits as well as the successful path. A missing Audio autoload/player or mix-cycle timeout now fails the boot test rather than silently skipping shutdown verification.
- No production audio scripts, scenes, assets, project settings, audio buses or gameplay behavior changed.

**Acceptance criteria**
- Both physics and boot smoke-test processes must verify player shutdown and observe a completed mix cycle.
- The final verbose Godot 4.7.2 workflow must show no retained MP3/ObjectDB warnings after either process.
- Existing import, parser, movement, collision, settings and menu checks remain enabled.

**Verification**
- Local Godot execution: unavailable; no Godot executable is installed in this environment.
- Latest pre-change CI evidence: [run 43170846659](https://github.com/Legioniz/LatchPoint/actions/runs/43170846659) passed the workflow steps but exposed the remaining boot-process shutdown warning. The follow-up resolved that second process's timing gap.
- Final Godot 4.7.2 GitHub Actions run [43174879566](https://github.com/Legioniz/LatchPoint/actions/runs/43174879566) passed resource import, every tracked GDScript parse check, the physics smoke test and the boot/settings test. The physics process observed a Dummy-driver mix reset after 10 process frames (44,100 Hz; initial next-mix estimate 0.0629 s); the boot process observed one after 2 frames (44,100 Hz; initial estimate 0.0089 s). The full verbose log contains no retained MP3/ObjectDB warnings, `ERROR` or `WARNING` lines after either smoke-test process.
- Manual desktop audio verification and performance profiling: not performed.
- Physics/collision behavior: unchanged; existing physics assertions remain enabled.
- ML: not used.

**Research:** existing Godot 4.7 AudioStreamPlayer and AudioServer API documentation plus Godot 4.7-stable AudioServer/Dummy-driver source; see the audio shutdown section in `RESEARCH_REGISTER.md`.

**Status:** both smoke-test shutdown paths are verified clean on the branch; issue #3 remains open until integration.

**Branch:** `fix/audio-mix-cycle-boot-smoke-shutdown`, based on `fix/audio-mix-cycle-shutdown` at `8226be2bf3b2fdef2412a8e3207a4e90889db4d7`. **Implementation commit:** `96f36a9f0e6c9ca905d20120668276cd5b322bc9`.


## 2026-11-18 — Consolidate smoke-test audio shutdown verification

**Objective:** remove duplicated audio shutdown test logic while preserving the clean per-process shutdown behavior established by the audio regression fix.

- Inspected PR #8 and its current head `31ada925876e611b02b6ec2f6830cf5f7b932a27`, both smoke-test scripts, the testing guide, and the complete verbose Godot 4.7.2 run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644).
- The run completed all validation steps successfully. The physics process observed the Dummy driver's mix reset after 11 process frames (44,100 Hz; initial next-mix estimate 0.0691 s); the boot process observed it after 2 process frames (44,100 Hz; initial estimate 0.0073 s). No retained MP3/ObjectDB warnings, `ERROR` or `WARNING` lines followed either smoke-test process.
- The two scripts duplicated the same shutdown contract and mix-cycle loop. Added `tests/audio_shutdown_verifier.gd` as a test-only RefCounted helper and routed both entrypoints through it.
- Preserved separate process-level calls and the existing distinction that the physics test requires active background playback before shutdown, while the boot test does not.
- No production audio script, scene, asset, bus, project setting, gameplay behavior or dependency changed.

**Acceptance criteria**
- Both smoke-test scripts use one shared shutdown implementation.
- Physics retains its active-playback precondition; boot retains its existing cleanup-only precondition.
- Missing Audio autoload/player, a retained stream/playback, or a mix-cycle timeout remains a test failure.
- Both verbose smoke-test processes complete without retained MP3/ObjectDB warnings.

**Verification**
- Research completed against Godot 4.7 AudioServer, SceneTree and GDScript coroutine documentation; see `RESEARCH_REGISTER.md`.
- GitHub Actions run [44255209541](https://github.com/Legioniz/LatchPoint/actions/runs/44255209541) passed on implementation commit `dc5a57ff97534209df9980affdd1752607297425`: Godot 4.7.2 install/version, resource import, every tracked GDScript parse (including the new helper), physics smoke test and boot smoke test all completed successfully.
- Full verbose output: physics process used the Dummy driver at 44,100 Hz, initial next-mix estimate 0.0602 s, observed mix reset after 9 process frames; boot process used 44,100 Hz, initial estimate 0.0856 s, observed reset after 13 process frames. No retained MP3/ObjectDB/StringName diagnostics or Godot `ERROR` lines followed either process. The inherited workflow still emits the Node.js 20 deprecation warning for `actions/checkout@v4`; modernization remains separately tracked in PR #11.
- Local Godot execution and desktop audio verification: not available/performed.
- Performance profiling: not performed; no runtime code changed.
- Physics/collision behavior: unchanged.
- ML: not used.

**Branch:** `feature/shared-audio-shutdown-verifier`, based on PR #8 head `fix/audio-mix-cycle-boot-smoke-shutdown`.

## 2026-11-19 — Verify debounced settings flush on tree exit

**Objective:** cover the actual Timer-backed save path and the Settings autoload's exit-tree flush, which the earlier persistence smoke test did not exercise because it used detached Settings instances and called save_now() directly.

- Extended the boot smoke test to add an isolated Settings instance to the active SceneTree, change a preference, and assert that the 0.5-second debounce timer is pending while the file is still absent.
- Free the in-tree fixture before the timer can process, exercising the real exit-tree callback; reload the isolated ConfigFile and verify the latest value was written.
- Capture and restore the root window's mode and borderless flag because a Settings instance applies its display preference during ready initialization.
- Keep the test file isolated under user://latchpoint_settings_smoke_test.cfg and remove it after verification.
- No production settings, audio, display, scene or gameplay code changed.

**Acceptance criteria**
- The Timer-backed save is pending after a preference change.
- No file is written before the debounce timeout.
- Leaving the SceneTree flushes the pending value.
- Reloading the isolated file returns the changed value.
- Existing defaults, round-trip, invalid-value recovery, audio integration and display-decoration assertions remain intact.

**Verification**
- Godot 4.7.2 GitHub Actions run [44478483715](https://github.com/Legioniz/LatchPoint/actions/runs/44478483715) completed successfully on implementation commit `9c34ea5299bc18e8db8d0d32517947a0c4f69d2e`: resource import, every tracked GDScript parse, physics/scene smoke test and boot/settings/display smoke test all passed, including the new debounce and exit-tree flush assertions.
- Full verbose output still reports two ObjectDB instances and one retained resource after both smoke-test processes. The audio path is the pre-existing issue #3 on this parent branch; this test-only change does not claim to resolve it.
- Local Godot execution and manual desktop/restart verification are not available in this cycle.
- This test exercises the exit-tree callback in the same process; it does not replace a separate-process application restart test.
- No runtime performance optimization or ML test was performed.


## 2026-11-20 — Integrate settings lifecycle with shared audio shutdown verification

**Objective:** combine the settings exit-tree regression from PR #15 with the shared audio shutdown verifier from PR #14 on one reviewable integration branch.

- Preserved PR #15's in-tree Settings fixture, pending debounce assertion, exit-tree flush assertion, and isolated-file cleanup.
- Preserved PR #14's shared `tests/audio_shutdown_verifier.gd` and physics-test integration.
- Updated the boot smoke test to use the same verifier, while retaining the settings lifecycle assertions and the boot test's cleanup-only playback precondition.
- Kept the two smoke-test commands as separate Godot processes; each process verifies its own AudioServer lifecycle.
- No production Settings.gd or AUDIO.gd code changed.

**Acceptance criteria**
- The physics test requires background playback to have started, stops and clears the player, observes a bounded AudioServer mix-age reset, and allows deferred cleanup frames.
- The boot test runs its settings lifecycle and display checks, then uses the same shutdown verifier and fails if verification fails.
- The settings debounce/exit-tree regression remains intact.
- The full verbose Godot 4.7.2 workflow passes and neither process emits retained MP3/ObjectDB/StringName diagnostics.

**Verification:** Godot 4.7.2 run [44689407205](https://github.com/Legioniz/LatchPoint/actions/runs/44689407205) passed on merge commit [6ece137](https://github.com/Legioniz/LatchPoint/commit/6ece1373b01cf40c37182895f6cf5c7ca0e18e88): resource import, every tracked GDScript parse check, physics/scene smoke test, and boot/settings smoke test all passed. The physics process used the Dummy driver at 44,100 Hz, initial next-mix estimate 0.0432 s, and observed a mix reset after 7 process frames; boot observed a reset after 9 frames (initial estimate 0.0612 s). The complete verbose log contained no retained ObjectDB, MP3 playback/resource, or StringName diagnostics and no Godot errors after either process. The inherited actions/checkout@v4 Node.js 20 deprecation notice remains tracked separately in PR #11.

**Branch:** `fix/settings-audio-shutdown-integration`, a child of PR #14 with PR #15 preserved as the second merge parent. A post-CI review restored audio shutdown attempts on the boot test's earliest menu-load and menu-instantiation failure paths.


## 2026-11-21 — Restore keyboard/controller focus across menus

**Objective:** complete a bounded part of the existing pause/menu UX backlog: make the existing menu flow usable without a mouse by establishing initial focus and deterministic vertical navigation.

- Added deferred initial focus to the main menu's Play button, the new/load menu's New Game button, and the options menu's Music slider.
- Added explicit vertical focus neighbors for the main menu, options menu and pause menu so arrow-key/D-pad movement follows the visible control order.
- Changed the pause menu's three buttons from `FOCUS_NONE` to `FOCUS_ALL`; the previous explicit setting made them impossible to focus by keyboard or controller.
- Focuses Resume whenever the pause menu opens and releases pause-menu focus when it closes. The existing Escape pause/resume behavior and scene transitions remain unchanged.
- Kept Load Game disabled and explicitly non-focusable.
- Extended the existing boot smoke test to send actual InputEventKey events through the viewport and assert initial focus, up/down navigation, disabled Load exclusion, Escape pause opening, and Space activation of Resume across all four menus.
- No new input actions, autoloads, dependencies, assets, gameplay mechanics or save data were introduced.

**Acceptance criteria**
- Each menu establishes a usable initial focus after entering the SceneTree.
- Visible interactive controls have focus enabled.
- Vertical keyboard navigation follows the intended visual order.
- The disabled Load Game control cannot receive focus.
- Escape opens the pause menu, focuses Resume, and Space activates Resume to restore gameplay.
- Existing settings, audio shutdown, physics and boot assertions remain enabled.

**Verification**
- Godot local execution: not available in this environment; runtime validation used the existing Godot 4.7.2 GitHub Actions workflow.
- Godot 4.7.2 GitHub Actions run [44880365084](https://github.com/Legioniz/LatchPoint/actions/runs/44880365084) passed the resource import, all tracked GDScript parse checks, physics/movement/collision-layer/audio-shutdown smoke tests, and boot/settings/display smoke test including the new keyboard focus assertions.
- Manual keyboard/gamepad and mouse verification: not performed.
- Physics/collision behavior: unchanged; no physics tests were altered.
- Performance: no runtime profiling performed; this is a small UI-focus change and no optimization is claimed.
- ML: not used; keyboard events are deterministic scripted tests, not machine learning.

**Research:** Godot 4.7 Keyboard/Controller Navigation and Focus tutorial and Control class reference; the official Godot demo-project UI Accessibility sample (MIT license) was inspected as an open-source UI reference. No external code or assets were copied. See `RESEARCH_REGISTER.md`.

**CI evidence:** the complete verbose run [44880365084](https://github.com/Legioniz/LatchPoint/actions/runs/44880365084) recorded physics audio shutdown on the Dummy driver at 44,100 Hz after 10 process frames and boot shutdown after 1 process frame. No retained MP3/ObjectDB/StringName diagnostics or Godot errors followed either process. The inherited `actions/checkout@v4` Node.js 20 deprecation notice remains tracked by PR #11.

**Branch:** `feature/menu-keyboard-focus`, based on PR #16's combined settings/audio integration head. **Implementation commit:** `905fe58cf88e7549e82f381b8b55b6694ea22a78`. **PR:** [#17](https://github.com/Legioniz/LatchPoint/pull/17), open draft stacked on PR #16.


## 2026-11-22 — Add gamepad confirm/cancel actions to menu navigation

**Objective:** complete the controller-input portion of the existing menu UX slice without changing gameplay controls or the unconfirmed core loop.

- Inspected the Godot 4.7.2 project configuration on the PR #17 branch. It had no project-level InputMap overrides; the engine's built-in `ui_up`/`ui_down` actions already include D-pad and left-stick navigation, but built-in `ui_accept` defaults to Enter/KP Enter/Space and `ui_cancel` defaults to Escape.
- Added a small `UIInput.gd` autoload that adds all-device Joypad A to `ui_accept` and Joypad B to `ui_cancel` only when those exact global-device bindings are absent. Existing keyboard and user-defined action events are preserved.
- Extended the boot smoke test with simulated D-pad navigation across the main, new/load, options and pause menus; it also verifies Joypad B pause/cancel behavior and Joypad A activation of the focused Resume button.
- Kept controller input in Godot's existing built-in UI actions; no gameplay input actions, player movement behavior, scenes, assets or third-party dependencies were added.
- Renamed the shared focus assertion diagnostic to "UI focus regression" because it now covers keyboard and gamepad events.

**Acceptance criteria**
- UIInput initializes before the main scene and leaves existing InputMap bindings intact.
- `ui_accept` contains a global Joypad A binding and `ui_cancel` contains a global Joypad B binding.
- D-pad navigation follows the existing explicit focus neighbors and never focuses disabled Load Game.
- Joypad B opens/closes pause through `ui_cancel`; Joypad A activates focused Resume through `ui_accept`.
- Existing keyboard, settings, display, physics and audio smoke checks remain enabled.

**Verification**
- Local Godot execution: not available in this environment.
- Godot 4.7.2 GitHub Actions: passed on final code commit `fedc2a2aea08ead77bbee8ef218aa06a752be9c3` in [run 44997848266](https://github.com/Legioniz/LatchPoint/actions/runs/44997848266): project resource import, every tracked GDScript parse check, physics/scene smoke tests and boot smoke tests all completed successfully. The boot log confirms keyboard/gamepad UI navigation and settings/display checks passed.
- Physical controller and native desktop testing: not performed; simulated joypad events verify the InputMap/Control path but do not validate SDL mappings or hardware behavior.
- Verbose CI evidence: physics audio shutdown used the Dummy driver at 44,100 Hz (initial next-mix estimate 0.0741 s; observed mix after 11 process frames); boot shutdown used the Dummy driver at 44,100 Hz (0.0715 s; 11 frames). No retained MP3/ObjectDB/StringName diagnostics or Godot errors were emitted. The inherited `actions/checkout@v4` Node.js 20 deprecation notice remains unrelated and is tracked by PR #11.
- Performance: no runtime profiling performed; the autoload adds two one-time InputMap lookups/conditional event additions during startup.
- ML: not used; this is deterministic input regression testing, not machine learning.

**Research:** Godot 4.7 InputEventJoypadButton, controller/gamepad input and GUI focus documentation, plus the 4.7-stable InputMap built-in action implementation. See `RESEARCH_REGISTER.md`.

**Branch:** `feature/gamepad-ui-actions`, based on `feature/menu-keyboard-focus`. Verification and final commit details will be added after CI.
