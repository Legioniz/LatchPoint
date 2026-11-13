# LatchPoint — Bot Task Board

**Last reviewed:** 2026-11-13  
**Purpose:** This is the coordination source of truth for agents contributing to LatchPoint. Suggested roles are not confirmed assignments. Check live GitHub issues, branches and PRs before claiming work.

## Working order

1. Reconcile the foundation PR against the latest `main` before integrating downstream branches.
2. Recover/review the unrepresented movement-regression parent branch before integrating PR #6 and its descendants.
3. Correct GitHub Actions trigger coverage for active branch prefixes and stacked PR targets.
4. Review the dependent PR stacks in their actual base/head order; do not merge automatically.
5. Keep issue #3 open until the audio shutdown fix is integrated, even though PR #8's branch CI is clean.
6. Obtain the product-owner decision for the core game loop. A neutral reference comparison is now prepared; no direction has been selected.
7. Expand physics/collision coverage only against agreed movement and gameplay rules.
8. Improve art, UX, progression and performance after the design and integration dependencies are ready.

## Active work and priorities

### LP-DOC-001 — Review shared bot guidance and daily QA documentation
- **Priority:** P2
- **Status:** In review.
- **Suggested role:** Project manager / technical writer / integration lead.
- **Evidence:** Draft [PR #5](https://github.com/Legioniz/LatchPoint/pull/5) adds AGENTS.md, PROJECT_CHARTER.md, ARCHITECTURE.md, FILE_STRUCTURE.md, BOT_TASK_BOARD.md, ISSUE_REGISTER.md and DAILY_QA_LOG.md, and links them from README.
- **Goal:** Give every contributor one authoritative place to find project purpose, architecture, file placement, issue state, priorities and contribution rules.
- **Acceptance:** Review all documents against the latest default and foundation branch trees; validate links; make sure no task is presented as assigned without a real owner; merge into the foundation branch only after review.
- **Branch:** `docs/daily-quality-management`
- **PR:** [#5](https://github.com/Legioniz/LatchPoint/pull/5)

### LP-QA-001 — Investigate MP3 playback references at shutdown

- **Priority:** P1
- **Status:** Verified on the PR #8 branch; pending integration. GitHub issue #3 remains open until the dependent change reaches the default branch.
- **Suggested role:** Audio systems + QA engineer.
- **Evidence:** The earlier [run 42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526) exposed retained ObjectDB/MP3 references. PR #8 adds cleanup verification to both independent smoke-test processes. Godot 4.7.2 [run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) completed successfully; the job log contains passing physics and boot smoke-test messages and no matching ObjectDB/MP3 shutdown warning lines.
- **Goal:** Keep the verified shutdown behavior in the integrated project and ensure future test processes follow the same lifecycle contract.
- **Likely files:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, `tests/boot_smoke_test.gd`, `.github/workflows/godot-validation.yml`.
- **Non-goals:** Do not remove music checks, suppress warnings or weaken physics assertions.
- **Acceptance:** Integrate the dependent PR stack, rerun Godot 4.7.2 CI on the resulting branch, and inspect full process logs for retained playback resources.
- **Issue:** [#3](https://github.com/Legioniz/LatchPoint/issues/3)
- **PR:** [#8](https://github.com/Legioniz/LatchPoint/pull/8)

### LP-DES-001 — Confirm the core game loop and design pillars
- **Priority:** P0
- **Status:** Blocked on product-owner/user direction; reference comparison prepared 2026-11-13.
- **Suggested role:** Game designer + research agent.
- **Goal:** Define the player promise, repeated action/feedback/reward loop, win/fail states, progression and first playable milestone.
- **Evidence:** `RESEARCH_REGISTER.md` now compares authored course surprise (`Super Mario Bros. Wonder`), precision movement challenge (`Celeste`) and compact exploration (`A Short Hike`), with Godot 4.7 and MIT-licensed demo-project references. The comparison is decision support only.
- **Non-goals:** Do not invent the mechanic from the name LatchPoint or commit to a genre based only on the prototype.
- **Acceptance:** Approved one-page concept with three to five design pillars and a testable first-playable scope.
- **Dependencies:** Product-owner decision. The owner may choose one of the researched patterns or specify a different direction.
- **Handoff:** Present the comparison and wait for direction before implementing a signature mechanic. After approval, prototype one short greybox slice and evaluate goal comprehension, input reliability, meaningful decisions, feedback and retry/continuation clarity.

### LP-QA-002 — Expand deterministic physics and collision tests
- **Priority:** P1
- **Status:** In review (partial layer/mask slice in PR #7); broader coverage remains open.
- **Suggested role:** Gameplay QA / physics engineer.
- **Goal:** Increase physics regression coverage beyond the current floor, wall and ceiling probes.
- **Evidence:** PR #7 checks that each enabled static platform in the current gameplay scene has a collision layer overlapping the real player's collision mask.
- **Likely files:** `tests/physics_smoke_test.gd`, `tests/physics_probe.gd`, possible test-only scenes.
- **Required scenarios:** corners, slopes, one-way platforms, moving platforms, high-speed movement/tunneling, spawn overlap, layers/masks, frame-rate consistency. Add item/pickup, hazard/projectile and power-up interactions when those systems exist.
- **Acceptance:** Each scenario has a reproducible setup, deterministic result and clear failure message; tests must validate real game objects where applicable, not only generic test probes.
- **Dependencies:** Confirm intended movement/collision rules before setting expected behavior.
- **PR:** [#7](https://github.com/Legioniz/LatchPoint/pull/7)

### LP-INT-001 — Review and settle the dependent foundation PR chain
- **Priority:** P1
- **Status:** In review; integration is blocked by stale and unrepresented parent branches.
- **Suggested role:** GitHub integration lead / senior reviewer.
- **Current repository evidence:** `main` is at `cc7b304d9636353c5de1a056955bd24168a4906c`. PR #1 is open/draft, GitHub reports it as not mergeable, and comparison shows its head 52 commits ahead and 5 behind `main` (merge base `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`). No merge or branch rewrite was performed.
- **Unrepresented parent dependency:** PR #6 targets `feature/player-movement-regression-tests`. That branch is 25 commits ahead of `feature/gameplay-foundation`, and no open or closed PR with that branch as its head appeared in the current PR listing. Recover or review its intended integration path before merging PR #6 or its descendants.
- **Current PR relationships:**
  1. [PR #1 — gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1), base `main`, head `feature/gameplay-foundation`. Reconcile the base and review the complete 40-file diff before integration.
  2. [PR #2 — fullscreen/window decoration fix](https://github.com/Legioniz/LatchPoint/pull/2), base `feature/gameplay-foundation`, head `fix/windowed-borderless-toggle`.
  3. [PR #4 — audio shutdown investigation docs](https://github.com/Legioniz/LatchPoint/pull/4), base `fix/windowed-borderless-toggle`, head `docs/audio-shutdown-leak-investigation`.
  4. [PR #5 — daily quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5), base `feature/gameplay-foundation`, head `docs/daily-quality-management`.
  5. [PR #6 — settings persistence](https://github.com/Legioniz/LatchPoint/pull/6), base `feature/player-movement-regression-tests`, head `feature/settings-persistence`.
  6. [PR #7 — platform collision-layer regression](https://github.com/Legioniz/LatchPoint/pull/7), base `feature/settings-persistence`, head `feature/physics-layer-mask-regressions`.
  7. [PR #8 — clean audio shutdown in both smoke-test processes](https://github.com/Legioniz/LatchPoint/pull/8), base `feature/physics-layer-mask-regressions`, head `fix/audio-mix-cycle-boot-smoke-shutdown`.
- **CI trigger gap:** the workflow currently pushes only on `main` and `feature/**`, while its pull-request trigger targets only `main`. This does not automatically cover the active `docs/**`/`fix/**` pushes or PRs targeting non-main branches. Run #43175060644 passed, but its event type was not available in the retrieved job details; do not infer that the current filters cover PR #8.
- **Goal:** Preserve intended dependency order and ensure each PR's base/head SHA, complete diff, review state and checks are current.
- **Acceptance:** Reconcile PR #1 with current `main` without force-push; recover/review the movement-regression parent; update CI filters and prove checks run on the intended PRs; review each dependent diff and manual-test limitation; merge only with explicit project-owner approval and required evidence.
- **Do not:** Retarget or merge downstream PRs before their dependencies are settled.

### LP-UI-001 — Verify display behavior on a real desktop
- **Priority:** P2
- **Status:** Needs manual verification.
- **Suggested role:** Desktop QA / UI engineer.
- **Goal:** Confirm fullscreen/windowed switching and native window decorations outside the headless DisplayServer.
- **Likely files:** `resolution.gd`, `options_menu.tscn`, `project.godot`, `tests/boot_smoke_test.gd`.
- **Acceptance:** Record OS, display setup and Godot version; test startup window, fullscreen on/off, title-bar/decorations, resize and restart behavior. Headless flag assertions do not prove real desktop mode behavior.
- **Related PR:** [#2](https://github.com/Legioniz/LatchPoint/pull/2)

### LP-AUD-001 — Classify remaining audio assets
- **Priority:** P2
- **Status:** Investigation required.
- **Suggested role:** Audio integrator / asset librarian.
- **Goal:** Establish intended use, license and owner of `Tung.mp3`, `maj.mp3` and `yi.mp3`.
- **Acceptance:** Record references, intended use and license/source. Keep assets unless safely proven redundant and approved for deletion.

### LP-SYS-001 — Persist options across application restart
- **Priority:** P2
- **Status:** Implemented and automated-tested on PR #6; in review, not yet integrated. Manual desktop restart/fullscreen verification remains pending.
- **Suggested role:** Systems engineer.
- **Goal:** Persist audio levels and display preferences with defaults and validation.
- **Acceptance:** Values survive restart, invalid settings recover safely, volume remains synchronized, and platform-specific settings are tested.
- **PR:** [#6](https://github.com/Legioniz/LatchPoint/pull/6)

### LP-SAVE-001 — Design and implement local save/load
- **Priority:** P2
- **Status:** Blocked by core loop and progression design.
- **Suggested role:** Persistence/backend engineer.
- **Goal:** Replace the disabled Load Game placeholder with a real versioned save/load system.
- **Acceptance:** Schema versioning, validation, atomic writes, backup/recovery, migration tests, multiple slots if needed, and an export/import format with integrity checks.
- **Non-goals:** Do not claim client-side locked/encrypted saves cannot be tampered with.

### LP-ARCH-001 — Propose a consistent directory migration
- **Priority:** P3
- **Status:** Planned; defer until the current PR chain is settled.
- **Suggested role:** Repository steward.
- **Goal:** Evaluate whether existing `Asset/`, `Scene/`, root scripts and `tests/` should be consolidated.
- **Acceptance:** Full dependency map, before/after tree, path/UID/import migration, Linux case-sensitive validation and rollback plan. No mass move until approved.

### LP-ART-001 — Replace prototype placeholder visuals
- **Priority:** P3
- **Status:** Blocked on visual direction and core game design.
- **Suggested role:** Art/UX agent.
- **Goal:** Replace icon-shaped platforms and temporary background with readable original visuals.
- **Acceptance:** Visuals support gameplay readability, collision boundaries remain clear, and assets are licensed/attributed.

## Suggested bot roles

| Role | Focus | Must coordinate with |
|---|---|---|
| Project manager / integrator | Priorities, task board, PR order, architecture decisions | All contributors |
| Research agent | Large and indie game comparisons, engine docs, design evidence | Designer / gameplay |
| Gameplay engineer | Player, world, interactions, abilities and progression | Physics QA / systems |
| UI/UX engineer | Menus, HUD, settings, input/accessibility | Gameplay / systems |
| QA / physics engineer | Reproduction, test scenes, collision and regression tests | All code contributors |
| Audio / asset librarian | Audio lifecycle, buses, asset references and licenses | QA / integrator |
| Persistence engineer | Settings, save schema, import/export and recovery | Gameplay / UI |
| Optimization engineer | Profiling, frame time, memory, loading and asset cost | Gameplay / rendering |

Do not create a task for a role unless there is actual work to perform. These are suggested specializations, not evidence of active bot identities or assignments.

## Task update format

For each task, retain: ID, priority, status, evidence, objective, player/project value, scope, non-goals, affected paths, dependencies/conflicts, suggested role, acceptance criteria, test proof, branch/PR/issue links, and next handoff.

Use statuses: proposed, ready, assigned, in progress, blocked, in review, completed. Only mark assigned when an actual contributor accepted or was assigned.
