# Improvement Backlog

Items are not promises to implement immediately. Re-score them after inspecting the current game and confirming the core loop.

## P0 — Foundation and design clarity

- [ ] **Confirm the core game loop and design pillars.** Goal: define what makes LatchPoint distinct before choosing major mechanics. Acceptance: a one-page concept with player promise, moment-to-moment loop, win/fail states, progression and three to five design pillars. A neutral comparison of course-based surprise, precision challenge and compact exploration patterns was added to `RESEARCH_REGISTER.md` on 2026-11-13; the owner decision remains pending.
- [ ] **Establish reliable GitHub Actions validation.** Goal: catch import, parser, scene-load and physics-smoke failures on every relevant branch/PR. Acceptance: workflow completes on Godot 4.7.2 and logs are reviewed; fix any failures rather than weakening the test. Workflow variants are inconsistent: the foundation/docs branch pushes only on `main` and `feature/**`, while the inspected movement/settings/physics/audio descendants also include `fix/**`; none of the inspected versions includes `docs/**`, and all restrict pull-request events to `main`. Thus docs branches are not push-triggered and stacked PRs targeting non-main branches do not receive pull-request-triggered checks. Run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) passed, but its event type was not available in the retrieved job details.
- [ ] **Resolve world presentation.** Goal: replace the temporary flat-color background and icon-shaped platform placeholders with a coherent, original art direction once the concept is confirmed. Acceptance: art style supports gameplay readability and does not obscure collision boundaries.

## P1 — Playable core and physics

- [ ] **Expand deterministic physics coverage.** Goal: test walls, ceilings, corners, slopes, one-way platforms, moving platforms, high-speed motion, collision masks and respawn overlap. Acceptance: each test is reproducible and has a regression assertion. PR #7 adds a current-scene static-platform layer/player-mask contract check; the broader scenarios remain open.
- [ ] **Tune player feel against the confirmed game loop.** Candidate controls: jump buffering, coyote time, variable jump height, air control and knockback. Acceptance: measured feel improvement, no unintended exploits, frame-step independence.
- [ ] **Audit all interactive collision geometry.** Goal: verify sprite/collision alignment and document layers/masks for players, platforms, hazards and interactables. Acceptance: visible collision-shape playtest and automated checks.
- [x] **Make options fully persistent.** Implemented on PR #6 with validated settings storage and automated persistence/integration tests. Manual desktop restart and native display behavior remain pending; the PR is still open and not integrated.
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

## Verified on downstream PR branches — not yet integrated

- [x] **Verify clean MP3 playback shutdown in both smoke-test processes (PR #8).** Godot 4.7.2 workflow run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) completed successfully; the job log contains the physics and boot smoke-test success messages without matching ObjectDB/MP3 shutdown warnings. Keep issue [#3](https://github.com/Legioniz/LatchPoint/issues/3) open until the dependent PR stack is integrated.
- [x] **Persist audio and fullscreen settings (PR #6).** Automated settings round-trip, validation and integration tests pass in the cited branch runs; manual desktop restart/fullscreen verification remains pending.
- [x] **Validate current static platform collision layers against the player mask (PR #7).** Automated assertion is present; slopes, one-way/moving platforms, corners, high-speed gameplay motion and respawn overlap remain untested.

These downstream items are implemented and tested on their respective open branches; they are not claims that the changes are already present on `main`.
