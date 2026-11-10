# Improvement Backlog

Items are not promises to implement immediately. Re-score them after inspecting the current game and confirming the core loop.

## P0 — Foundation and design clarity

- [ ] **Confirm the core game loop and design pillars.** Goal: define what makes LatchPoint distinct before choosing major mechanics. Acceptance: a one-page concept with player promise, moment-to-moment loop, win/fail states, progression and three to five design pillars.
- [x] **Establish reliable GitHub Actions validation.** Goal: catch import, parser, scene-load and physics-smoke failures on every relevant branch/PR. Acceptance: workflow completes on Godot 4.7.2 and logs are reviewed; fix any failures rather than weakening the test. Verified on 2026-11-10 with the import, GDScript parse, expanded physics/movement and boot checks passing (run [42772488665](https://github.com/Legioniz/LatchPoint/actions/runs/42772488665)). Audio shutdown warnings remain a separate open issue (#3).
- [ ] **Resolve world presentation.** Goal: replace the temporary flat-color background and icon-shaped platform placeholders with a coherent, original art direction once the concept is confirmed. Acceptance: art style supports gameplay readability and does not obscure collision boundaries.

## P1 — Playable core and physics

- [ ] **Resolve MP3 playback references retained at test shutdown ([issue #3](https://github.com/Legioniz/LatchPoint/issues/3)).** Goal: determine why the physics smoke-test process reports retained `AudioStreamPlaybackMP3` / `AudioStreamMP3` resources after the audio autoload is stopped. Acceptance: reproduce on CI, identify project-owned references versus asynchronous AudioServer cleanup, add a deterministic regression check where possible, and remove the warning or document a verified engine limitation without suppressing it.
- [x] **Lock down the current player movement baseline.** The physics smoke test now instantiates the real player scene and checks configured horizontal acceleration, friction, grounded jump velocity, gravity response, and rejection of a second jump while airborne. This is a regression baseline, not a claim that the game's final movement feel is approved. See the 2026-11-10 entry in `IMPROVEMENT_LOG.md`.
- [ ] **Expand deterministic physics coverage.** Goal: test walls, ceilings, corners, slopes, one-way platforms, moving platforms, high-speed motion, collision masks and respawn overlap. Acceptance: each test is reproducible and has a regression assertion.
- [ ] **Tune player feel against the confirmed game loop.** Candidate controls: jump buffering, coyote time, variable jump height, air control and knockback. Acceptance: measured feel improvement, no unintended exploits, frame-step independence.
- [ ] **Audit all interactive collision geometry.** Goal: verify sprite/collision alignment and document layers/masks for players, platforms, hazards and interactables. Acceptance: visible collision-shape playtest and automated checks.
- [x] **Make options fully persistent.** Master/Music/SFX linear volumes and fullscreen preference now load from and save to `user://settings.cfg`, with validated defaults and debounced writes. Godot 4.7.2 CI passed on 2026-11-10 (run [42775181753](https://github.com/Legioniz/LatchPoint/actions/runs/42775181753)); native desktop restart/window behavior still needs manual verification. Gameplay save/load remains separate.
- [ ] **Finish pause and menu UX.** Goal: responsive layout, keyboard/gamepad focus, consistent transitions and meaningful disabled states. Acceptance: every control works or clearly explains why unavailable.

## P2 — Game systems (dependent on core-loop decision)

- [ ] **Items, tools and pickups.** Goal: introduce only items that create meaningful player decisions. Acceptance: pickup/trigger collision, duplicate protection, feedback, inventory/state changes and tests.
- [ ] **Power-ups and upgrades.** Goal: build balanced progression with explicit stack/expiry/unlock rules. Acceptance: UI, audio, save representation and edge-case tests are integrated.
- [ ] **World, enemies and hazards.** Goal: introduce reusable scenes and readable encounters. Acceptance: AI/state transitions, hitboxes, damage/cooldowns, difficulty pacing and collision regression tests.
- [ ] **Checkpoints and level progression.** Goal: make retry and progression understandable. Acceptance: correct respawn transforms, unlock rules and no soft-locks.

## P3 — Persistence, agents and release

- [ ] **Local save/load.** Goal: persist settings, checkpoints and progression with versioning. Acceptance: atomic writes, validation, backups, migrations, corrupted-save recovery and repeatable tests. This is gameplay-progress persistence and remains separate from the completed options-settings slice.
- [ ] **Export/import save package.** Goal: allow users to export and restore a compatible save. Acceptance: version metadata, integrity checks, clear locked-state semantics and graceful incompatibility handling.
- [ ] **ML-assisted playtesting.** Goal: evaluate a local agent only when a measurable objective and game-state interface exist. Acceptance: repeatable traces identify a bug or a measurable coverage gap; compare with deterministic and human tests.
- [ ] **Performance baseline and profiling.** Goal: establish frame-time, load-time, memory and physics budgets on target hardware. Acceptance: profiler evidence and before/after metrics for optimizations.

## Resolved in the current foundation PR

- [x] Consolidated player horizontal movement so acceleration/friction are not overwritten by a second velocity calculation.
- [x] Routed New Game to the existing gameplay scene; disabled Load Game until save support exists.
- [x] Replaced the placeholder menu title.
- [x] Corrected the music path and synchronized the in-memory audio setting with the slider across scene changes.
- [x] Repaired pause-menu integration and missing callback targets.
- [x] Replaced a missing gameplay background reference with a temporary built-in color fallback.
- [x] Removed confirmed copied Git metadata and unreferenced empty prototype scripts/scenes after reference checks.
- [x] Fixed fullscreen/windowed switching so windowed mode restores native window decorations (separate follow-up branch).
