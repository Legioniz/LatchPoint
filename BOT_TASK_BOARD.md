# LatchPoint — Bot Task Board

**Last reviewed:** 2026-11-14  
**Purpose:** This is the coordination source of truth for agents contributing to LatchPoint. Suggested roles are not confirmed assignments. Check live GitHub issues, branches and PRs before claiming work.

## Working order

1. Confirm the repository visibility policy and protect `main`; the repository currently reports public and main is unprotected.
2. Reconcile PR #1 with current main without rewriting shared history; resolve the independent README additions and preserve the current copyright/license files.
3. Recover and review the unrepresented `feature/player-movement-regression-tests` parent before integrating PR #6 or descendants.
4. Preserve PR #11's catch-all CI triggers and pinned actions when reconciling the other feature/docs branches; their current workflow files still have narrower filters.
5. Integrate the PR #8 audio shutdown fix with the settings/physics stack, then rerun both smoke-test processes and inspect full logs; issue #3 remains open because the PR #11 line still reproduces the warning.
6. Bring the current `TESTING_GUIDE.md` into the shared documentation line after the feature stack settles.
7. Keep the core game-loop decision blocked on product-owner direction; do not infer a mechanic from the title.
8. Expand physics/collision coverage only against agreed movement and gameplay rules.
9. Improve art, UX, progression and performance after design and integration dependencies are ready.

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
- **Status:** Open / in review. Clean on PR #8's head, but reproduced on the separate foundation/CI PR #11 line; issue #3 remains open.
- **Suggested role:** Audio systems + QA engineer.
- **Evidence:** [Run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) on `fix/audio-mix-cycle-boot-smoke-shutdown` passed Godot 4.7.2 import/parse/physics/boot checks; the full log shows mix resets after 11 physics frames and 2 boot frames with no retained MP3/ObjectDB warnings. In contrast, Godot 4.7.2 [push run 43570349587](https://github.com/Legioniz/LatchPoint/actions/runs/43570349587) and [PR run 43570448230](https://github.com/Legioniz/LatchPoint/actions/runs/43570448230) on `ci/branch-wide-godot-validation` both complete successfully but report two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 and `res://Project_bullshit.mp3` after each smoke-test process.
- **Goal:** Keep the clean shutdown behavior in the integrated project and ensure both independent test processes follow the same lifecycle contract.
- **Likely files:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, `tests/boot_smoke_test.gd`, `.github/workflows/godot-validation.yml`.
- **Non-goals:** Do not remove music checks, suppress warnings or weaken physics assertions.
- **Acceptance:** Integrate the PR #8 change with the current settings/physics/CI stack, run Godot 4.7.2 validation on the integrated head, and inspect full logs for both processes. Keep issue [#3](https://github.com/Legioniz/LatchPoint/issues/3) open until clean integrated evidence exists.
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
- **Branch/PR:** `docs/core-loop-reference-research`, draft [PR #9](https://github.com/Legioniz/LatchPoint/pull/9) targeting `docs/daily-quality-management`.

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
- **Status:** In review; integration is blocked by stale and unrepresented parent branches and divergent CI workflow changes.
- **Suggested role:** GitHub integration lead / senior reviewer.
- **Current repository evidence:** `main` is at `097da44e4ad3fb2a3f1e762034855ef46cffdac4`. PR #1 targets main from `feature/gameplay-foundation`; GitHub reports `mergeable=false` / `dirty`, and comparison shows 52 commits ahead and 9 behind. Both main and PR #1 independently add `README.md`; reconcile that add/add conflict. Do not force-push or rewrite the shared branch.
- **Unrepresented parent dependency:** PR #6 targets `feature/player-movement-regression-tests`. That branch is 25 commits ahead of `feature/gameplay-foundation`, and no PR with it as head appeared in the all-state PR inventory. Recover/review its intended integration path before PR #6 or descendants.
- **Current PR relationships:**
  1. [PR #1 — gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1), base `main`, head `feature/gameplay-foundation`; dirty against current main.
  2. [PR #2 — fullscreen/window decoration fix](https://github.com/Legioniz/LatchPoint/pull/2), base `feature/gameplay-foundation`, head `fix/windowed-borderless-toggle`.
  3. [PR #4 — audio shutdown investigation docs](https://github.com/Legioniz/LatchPoint/pull/4), base `fix/windowed-borderless-toggle`, head `docs/audio-shutdown-leak-investigation`.
  4. [PR #5 — daily quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5), base `feature/gameplay-foundation`, head `docs/daily-quality-management`.
  5. [PR #6 — settings persistence](https://github.com/Legioniz/LatchPoint/pull/6), base `feature/player-movement-regression-tests`, head `feature/settings-persistence`.
  6. [PR #7 — platform collision-layer regression](https://github.com/Legioniz/LatchPoint/pull/7), base `feature/settings-persistence`, head `feature/physics-layer-mask-regressions`.
  7. [PR #8 — clean audio shutdown in both smoke-test processes](https://github.com/Legioniz/LatchPoint/pull/8), base `feature/physics-layer-mask-regressions`, head `fix/audio-mix-cycle-boot-smoke-shutdown`.
  8. [PR #9 — core-loop reference research](https://github.com/Legioniz/LatchPoint/pull/9), base `docs/daily-quality-management`, head `docs/core-loop-reference-research`.
  9. [PR #10 — daily QA audit](https://github.com/Legioniz/LatchPoint/pull/10), base `docs/core-loop-reference-research`, head `quality/daily-audit-2026-11-13`.
  10. [PR #11 — branch-wide CI validation](https://github.com/Legioniz/LatchPoint/pull/11), base `feature/gameplay-foundation`, head `ci/branch-wide-godot-validation`.
- **CI integration conflict:** PR #11 uses catch-all `**` push/PR filters and pins Node 24-compatible action commits. The older workflow on the movement, settings/physics/audio and docs lines still uses `main`, `feature/**`, `fix/**` push filters and PR targets limited to `main`. The new workflow is not propagated to those branches; merging a stale descendant workflow later could restore old filters/action versions.
- **Goal:** Preserve dependency order and ensure every PR's base/head SHA, complete diff, review state and checks are current.
- **Acceptance:** Reconcile PR #1 with current main without force-push; recover/review the movement-regression parent; preserve PR #11's workflow policy across descendants; integrate the audio fix with settings/physics; verify all resource paths and full CI logs; merge only with explicit project-owner approval.
- **Do not:** Retarget or merge downstream PRs before their dependencies are settled.
- **Branch/PR:** Existing draft stack #1–#11; no new integration branch created.

### LP-SEC-001 — Confirm repository visibility and protect main

- **Priority:** P1
- **Status:** Blocked on owner confirmation; no GitHub settings changed.
- **Problem/evidence:** Repository metadata reports `public`; the project request describes it as private. GitHub reports `main` and all listed refs as unprotected.
- **Goal/value:** Ensure source visibility and integration controls match the intended ownership/access policy.
- **Scope:** Confirm public/private intent; if private is intended, review collaborators/forks and change repository visibility; enable PR-only protection and required CI checks on main.
- **Non-goals:** Do not change visibility or protection without owner authorization; do not alter licenses as a substitute for access control.
- **Likely affected systems:** GitHub repository settings, main branch rules, required CI status checks.
- **Dependencies/conflicts:** Owner policy decision; choose required check names only after the final workflow is agreed.
- **Suggested role:** Repository administrator / security reviewer.
- **Acceptance:** Repository visibility matches the documented intent; main rejects direct pushes and requires approved PRs plus the required checks; evidence is recorded in the task board.
- **Required proof:** Re-read GitHub repository visibility and branch-protection metadata after the authorized settings change.
- **Branch/PR/issue:** No issue or PR created; owner decision pending.

### LP-DOC-002 — Synchronize the current testing guide into shared documentation

- **Priority:** P3
- **Status:** Proposed; defer until the feature/test stack settles.
- **Problem/evidence:** `TESTING_GUIDE.md` exists on `feature/physics-layer-mask-regressions` and `fix/audio-mix-cycle-boot-smoke-shutdown`, but is absent from the docs PR #10 base `docs/core-loop-reference-research`.
- **Goal/value:** Give every contributor one current source for import, parse, physics, settings, audio shutdown and manual desktop verification.
- **Scope:** Bring the latest compatible guide into the shared docs line; verify its commands and descriptions against the integrated tests; link it from README and AGENTS.
- **Non-goals:** Do not copy a stale guide, add a testing framework, or duplicate test code.
- **Likely files:** `TESTING_GUIDE.md`, `README.md`, `AGENTS.md`, test scripts.
- **Dependencies/conflicts:** PR #5/#9 documentation stack and PR #6/#7/#8 test/code stack must be reconciled first.
- **Suggested role:** QA documentation / technical writer.
- **Acceptance:** Guide exists on the shared docs base, all commands match the current tree, limitations are explicit, and relative links resolve.
- **Required tests/proof:** Markdown link/path check plus the documented Godot commands on the integrated branch.
- **Branch/PR/issue:** No branch or PR created; proposed task.

### LP-REPO-001 — Review copied Git metadata on legacy refs

- **Priority:** P3
- **Status:** Proposed investigation; no branch or file deleted.
- **Problem/evidence:** Main retains root `config`, `description` and binary `index`; `automation/playability-baseline` retains tracked `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD`. PR #1 already removes the main-branch copies.
- **Goal/value:** Keep repository history and active branches free of accidental Git internals without destroying historical work.
- **Scope:** Confirm the old automation branch's purpose and references; preserve PR #1's cleanup; remove metadata only in a reviewed focused change if safe.
- **Non-goals:** Do not delete the branch, rewrite history or duplicate PR #1 cleanup.
- **Likely paths:** `config`, `description`, `index`, `COMMIT_EDITMSG`, `FETCH_HEAD`, `HEAD`.
- **Dependencies/conflicts:** PR #1 cleanup and branch-owner intent.
- **Suggested role:** Repository steward.
- **Acceptance:** Each tracked metadata file has an explicit disposition and no active PR/branch dependency is overwritten.
- **Required proof:** Tree/history/reference review and a focused diff; no Godot test is needed unless project files change.
- **Branch/PR/issue:** No branch or PR created; proposed task.

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
