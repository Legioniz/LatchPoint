# Improvement Log

Each completed cycle records its purpose, affected files, sources, verification evidence, remaining risks and PR/commit link. Unrun tests are explicitly marked as unverified.

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


## 2026-11-17 — High-speed solid-collision regression coverage

**Objective:** extend the deterministic physics baseline to cover high-speed motion through the existing floor, wall and ceiling probe fixtures without changing the unconfirmed game loop.

- Added three high-speed CharacterBody2D probe cases to tests/physics_smoke_test.gd: floor, wall and ceiling.
- The commanded speed is derived from the configured physics tick rate so the probe travels exactly 100 pixels per physics tick (6,000 pixels/second at the 60 Hz default).
- Each test uses the existing 20-pixel probe and 20-pixel-thick obstacle, waits through the existing 30-physics-frame window, then checks the expected floor/wall/ceiling classification and verifies that the body did not pass through the surface.
- Added distinct case labels so a failure identifies the high-speed surface under test.
- Updated the backlog and testing guide to distinguish completed high-speed surface checks from still-uncovered corners, slopes, one-way/moving platforms and respawn overlap.
- Added the Godot 4.7 CharacterBody2D reference and MIT-licensed official demo-project comparison to RESEARCH_REGISTER.md. No external source or assets were copied.
- No shipping gameplay script, scene, asset, project setting, collision shape, input map or dependency changed.

**Acceptance and verification plan**
- Keep all existing scene, player movement, collision-layer and normal-speed collision assertions.
- Run the existing Godot 4.7.2 import, tracked-GDScript parse, physics smoke and boot smoke workflow.
- Require all three high-speed cases to report the correct surface and no penetration.
- Inspect the complete verbose logs for failures and retain any unrelated shutdown warnings.

**Verification**
- Baseline before change: Godot 4.7.2 run [42772655494](https://github.com/Legioniz/LatchPoint/actions/runs/42772655494) passed all existing steps. Its verbose physics and boot process logs still showed the known MP3/ObjectDB/StringName shutdown warnings tracked by issue #3.
- Local Godot execution: not available in this environment.
- Initial post-change Godot 4.7.2 run [44034665292](https://github.com/Legioniz/LatchPoint/actions/runs/44034665292) completed successfully. Its physics smoke-test process showed the known audio/ObjectDB shutdown warning; its boot process did not show that warning.
- Implementation-head run [44034796475](https://github.com/Legioniz/LatchPoint/actions/runs/44034796475) completed successfully: resource import, all tracked GDScript parsing, physics smoke test and boot smoke test passed. The physics success line explicitly confirms normal-speed and high-speed floor, wall and ceiling checks.
- Run 44034796475 reported two ObjectDB instances, one retained AudioStreamMP3 / AudioStreamPlaybackMP3 for res://Project_bullshit.mp3, and an orphan Music StringName after both smoke-test processes. This is the pre-existing issue #3 and remains unresolved; the warnings are not hidden.
- Final branch-head run [44034964011](https://github.com/Legioniz/LatchPoint/actions/runs/44034964011) also passed import, all tracked GDScript parsing, the physics smoke test and boot smoke test. Its physics process retained the same issue #3 audio/ObjectDB/StringName warnings; its boot process completed without those warnings.
- The inherited workflow still emits the actions/checkout@v4 Node.js 20 deprecation warning; CI workflow modernization is tracked separately in PR #11.
- Manual in-game collision visualization: not performed.
- Performance profiling: not performed; this is test-only code.
- ML: not used; the probes are deterministic scripted physics tests, not machine learning.

**Branch:** feature/high-speed-collision-regressions, based on feature/player-movement-regression-tests.
