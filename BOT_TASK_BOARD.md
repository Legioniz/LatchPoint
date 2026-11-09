# LatchPoint — Bot Task Board

**Last reviewed:** 2026-11-09  
**Purpose:** This is the coordination source of truth for agents contributing to LatchPoint. Suggested roles are not confirmed assignments. Check live GitHub issues, branches and PRs before claiming work.

## Working order

1. Protect and stabilize the foundation PR chain.
2. Resolve the observed audio shutdown resource warning.
3. Expand repeatable physics/collision coverage.
4. Confirm the core game direction before designing major new mechanics.
5. Improve persistence, settings, UI, art and performance when dependencies are ready.

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
- **Status:** In progress / tracked by GitHub issue #3.
- **Suggested role:** Audio systems + QA engineer.
- **Evidence:** CI run [42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526) passes physics assertions but then reports two leaked ObjectDB instances, one resource still in use, and retained AudioStreamPlaybackMP3 / AudioStreamMP3 references to `res://Project_bullshit.mp3`.
- **Goal:** Determine whether the retained reference is caused by project-owned references, test shutdown timing, the audio driver or an engine lifecycle limitation.
- **Likely files:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, `.github/workflows/godot-validation.yml`.
- **Non-goals:** Do not remove music checks, suppress warnings or weaken physics assertions.
- **Acceptance:** Reproduce, isolate the cause, add a deterministic regression check where possible, and show clean shutdown or document a minimal verified engine limitation.
- **Issue:** [#3](https://github.com/Legioniz/LatchPoint/issues/3)

### LP-DES-001 — Confirm the core game loop and design pillars

- **Priority:** P0
- **Status:** Blocked on product-owner/user direction.
- **Suggested role:** Game designer + research agent.
- **Goal:** Define the player promise, repeated action/feedback/reward loop, win/fail states, progression and first playable milestone.
- **Likely files:** `PROJECT_CHARTER.md`, `IMPROVEMENT_BACKLOG.md`, `RESEARCH_REGISTER.md`.
- **Non-goals:** Do not invent the mechanic from the name LatchPoint or commit to a genre based only on the prototype.
- **Acceptance:** Approved one-page concept with three to five design pillars and a testable first-playable scope.
- **Dependencies:** User/product-owner decision.
- **Handoff:** Research agent should prepare examples from at least one larger and one smaller/independent game, then present a short comparison and recommendation.

### LP-QA-002 — Expand deterministic physics and collision tests

- **Priority:** P1
- **Status:** Ready after reviewing the current tests and core movement assumptions.
- **Suggested role:** Gameplay QA / physics engineer.
- **Goal:** Increase physics regression coverage beyond the current floor, wall and ceiling probes.
- **Likely files:** `tests/physics_smoke_test.gd`, `tests/physics_probe.gd`, possible test-only scenes.
- **Required scenarios:** corners, slopes, one-way platforms, moving platforms, high-speed movement/tunneling, spawn overlap, layers/masks, frame-rate consistency. Add item/pickup, hazard/projectile and power-up interactions when those systems exist.
- **Acceptance:** Each scenario has a reproducible setup, deterministic result and clear failure message; tests must validate real game objects where applicable, not only generic test probes.
- **Dependencies:** Confirm intended movement/collision rules before setting expected behavior.

### LP-INT-001 — Review and settle the dependent foundation PR chain

- **Priority:** P1
- **Status:** In review; do not merge automatically.
- **Suggested role:** GitHub integration lead / senior reviewer.
- **Current chain:**
  1. [PR #1 — gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1), base `main`, head `feature/gameplay-foundation`.
  2. [PR #2 — fullscreen/window decoration fix](https://github.com/Legioniz/LatchPoint/pull/2), base `feature/gameplay-foundation`, head `fix/windowed-borderless-toggle`.
  3. [PR #4 — audio shutdown investigation docs](https://github.com/Legioniz/LatchPoint/pull/4), base `fix/windowed-borderless-toggle`, head `docs/audio-shutdown-leak-investigation`.
  4. [PR #5 — daily quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5), base `feature/gameplay-foundation`, head `docs/daily-quality-management`.
- **Goal:** Preserve intended dependency order and ensure each PR's base/head SHA and checks are current.
- **Acceptance:** Review each complete diff, review comments, CI logs and manual-test limitations; merge only with explicit project-owner approval and required evidence.
- **Do not:** Retarget or merge downstream PRs before their dependencies are settled.

### LP-UI-001 — Verify display behavior on a real desktop

- **Priority:** P2
- **Status:** Needs manual verification.
- **Suggested role:** Desktop QA / UI engineer.
- **Goal:** Confirm fullscreen/windowed switching and native window decorations outside the headless DisplayServer.
- **Likely files:** `resolution.gd`, `options_menu.tscn`, `project.godot`, `tests/boot_smoke_test.gd`.
- **Acceptance:** Record OS, display setup and Godot version; test startup window, fullscreen on/off, title-bar/decorations, resize and restart behavior. Headless flag assertions do not prove real desktop mode behavior.

### LP-AUD-001 — Classify remaining audio assets

- **Priority:** P2
- **Status:** Investigation required.
- **Suggested role:** Audio integrator / asset librarian.
- **Goal:** Establish intended use, license and owner of `Tung.mp3`, `maj.mp3` and `yi.mp3`.
- **Acceptance:** Record references, intended use and license/source. Keep assets unless safely proven redundant and approved for deletion.

### LP-SYS-001 — Persist options across application restart

- **Priority:** P2
- **Status:** Proposed.
- **Suggested role:** Systems engineer.
- **Goal:** Persist audio levels and display preferences with defaults and validation.
- **Likely files:** `AUDIO.gd`, `Music-Control.gd`, `resolution.gd`, a future settings resource/service and tests.
- **Acceptance:** Values survive restart, invalid settings recover safely, volume remains synchronized, and platform-specific settings are tested.
- **Dependency:** Agree on a configuration/save ownership model first.

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

Use statuses: proposed, ready, assigned, in progress, blocked, in review, completed. Only mark assigned when an actual contributor accepted or was assigned the task.
