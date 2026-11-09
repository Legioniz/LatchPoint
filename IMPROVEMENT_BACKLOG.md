# Improvement Backlog

Items are not promises to implement immediately. Re-score them after inspecting the current game and confirming the core loop.

## P0 — Foundation and design clarity

- [ ] **Confirm the core game loop and design pillars.** Goal: define what makes LatchPoint distinct before choosing major mechanics. Acceptance: a one-page concept with player promise, moment-to-moment loop, win/fail states, progression and three to five design pillars.
- [ ] **Establish reliable GitHub Actions validation.** Goal: catch import, parser, scene-load and physics-smoke failures on every relevant branch/PR. Acceptance: workflow completes on Godot 4.7.2 and logs are reviewed; fix any failures rather than weakening the test.
- [ ] **Resolve world presentation.** Goal: replace the temporary flat-color background and icon-shaped platform placeholders with a coherent, original art direction once the concept is confirmed. Acceptance: art style supports gameplay readability and does not obscure collision boundaries.

## P1 — Playable core and physics

- [ ] **Expand deterministic physics coverage.** Goal: test walls, ceilings, corners, slopes, one-way platforms, moving platforms, high-speed motion, collision masks and respawn overlap. Acceptance: each test is reproducible and has a regression assertion.
- [ ] **Tune player feel against the confirmed game loop.** Candidate controls: jump buffering, coyote time, variable jump height, air control and knockback. Acceptance: measured feel improvement, no unintended exploits, frame-step independence.
- [ ] **Audit all interactive collision geometry.** Goal: verify sprite/collision alignment and document layers/masks for players, platforms, hazards and interactables. Acceptance: visible collision-shape playtest and automated checks.
- [ ] **Make options fully persistent.** Goal: save audio and display settings locally and restore them safely. Acceptance: settings survive application restart and invalid settings recover to defaults.
- [ ] **Finish pause and menu UX.** Goal: responsive layout, keyboard/gamepad focus, consistent transitions and meaningful disabled states. Acceptance: every control works or clearly explains why unavailable.

## P2 — Game systems (dependent on core-loop decision)

- [ ] **Items, tools and pickups.** Goal: introduce only items that create meaningful player decisions. Acceptance: pickup/trigger collision, duplicate protection, feedback, inventory/state changes and tests.
- [ ] **Power-ups and upgrades.** Goal: build balanced progression with explicit stack/expiry/unlock rules. Acceptance: UI, audio, save representation and edge-case tests are integrated.
- [ ] **World, enemies and hazards.** Goal: introduce reusable scenes and readable encounters. Acceptance: AI/state transitions, hitboxes, damage/cooldowns, difficulty pacing and collision regression tests.
- [ ] **Checkpoints and level progression.** Goal: make retry and progression understandable. Acceptance: correct respawn transforms, unlock rules and no soft-locks.

## P3 — Persistence, agents and release

- [ ] **Local save/load.** Goal: persist settings, checkpoints and progression with versioning. Acceptance: atomic writes, validation, backups, migrations, corrupted-save recovery and repeatable tests.
- [ ] **Export/import save package.** Goal: allow users to export and restore a compatible save. Acceptance: version metadata, integrity checks, clear locked-state semantics and graceful incompatibility handling.
- [ ] **ML-assisted playtesting.** Goal: evaluate a local agent only when a measurable objective and game-state interface exist. Acceptance: repeatable traces identify a bug or a measurable coverage gap; compare with deterministic and human tests.
- [ ] **Performance baseline and profiling.** Goal: establish frame-time, load-time, memory and physics budgets on target hardware. Acceptance: profiler evidence and before/after metrics for optimizations.
- [ ] **Release/export pipeline.** Goal: reproducible builds for the chosen platforms. Acceptance: clean export, launch verification, versioning and documented build steps.

## Resolved in the current foundation PR

- [x] Consolidated player horizontal movement so acceleration/friction are not overwritten by a second velocity calculation.
- [x] Routed New Game to the existing gameplay scene; disabled Load Game until save support exists.
- [x] Replaced the placeholder menu title.
- [x] Corrected the music path and synchronized the in-memory audio setting with the slider across scene changes.
- [x] Repaired pause-menu integration and missing callback targets.
- [x] Replaced a missing gameplay background reference with a temporary built-in color fallback.
- [x] Removed confirmed copied Git metadata and unreferenced empty prototype scripts/scenes after reference checks.

