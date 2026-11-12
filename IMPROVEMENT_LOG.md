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
