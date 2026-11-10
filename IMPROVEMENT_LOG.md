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
- Godot 4.7.2 GitHub Actions validation: passed on 2026-11-10 in run [42774794219](https://github.com/Legioniz/LatchPoint/actions/runs/42774794219): resource import, every tracked GDScript parse check, physics smoke test, and boot/settings persistence test all completed successfully.
- Manual desktop fullscreen/restart verification: pending; headless tests cannot verify native title-bar behavior on a real desktop.
- Performance: no runtime profiler was available. The 0.5-second debounce is a write-frequency safeguard, not a measured performance improvement.
- The same CI logs still report two ObjectDB instances and one `AudioStreamMP3` resource retained at shutdown for `res://Project_bullshit.mp3` after both smoke-test processes. This remains the separate, unresolved issue [#3](https://github.com/Legioniz/LatchPoint/issues/3); no Settings.gd resource leak or out-of-tree Node-path errors remained after the test fixtures were explicitly freed.
- ML: not used.

**Research:** Godot 4.7 ConfigFile and user-data-path documentation; MIT-licensed Godot Settings Menu Lite as an open-source architectural comparison; a Godot ConfigFile settings tutorial. See `RESEARCH_REGISTER.md`.

**Branch:** `feature/settings-persistence`, based on `feature/player-movement-regression-tests`. **Commit:** `79247183725cc22cca3796e663d91aa58c892ee3` plus test-cleanup follow-up `0986d559cfafdbb3de88fb129dbc7ea8dafb6444`.

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
