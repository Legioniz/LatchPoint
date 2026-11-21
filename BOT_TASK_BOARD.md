# LatchPoint — Bot Task Board

**Last reviewed:** 2026-11-19  
**Purpose:** This is the coordination source of truth for agents contributing to LatchPoint. Suggested roles are not confirmed assignments. Check live GitHub issues, branches and PRs before claiming work.

## Working order

1. Confirm the repository visibility policy and protect `main`; the repository currently reports public and main is unprotected.
2. Reconcile PR #1 with current main without rewriting shared history; resolve the independent README additions and preserve the current copyright/license files.
3. Recover and review the unrepresented `feature/player-movement-regression-tests` parent before integrating PR #6 or descendants.
4. Preserve PR #11's catch-all CI triggers and pinned actions when reconciling the other feature/docs branches; their current workflow files still have narrower filters.
5. Review PR #14's shared test-only audio shutdown verifier and clean branch-head logs; integrate it with the settings/physics/sidecar/CI stack in dependency order, then rerun both smoke-test processes on the resulting shared head. Keep issue #3 open until that integrated run is clean.
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
- **Status:** Clean on the combined downstream integration head PR #16; issue #3 remains open until the stack reaches main and a main-based run confirms clean shutdown.
- **Suggested role:** Audio systems + QA engineer.
- **Evidence:** [Run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) on `fix/audio-mix-cycle-boot-smoke-shutdown` passed Godot 4.7.2 import/parse/physics/boot checks; the full log shows mix resets after 11 physics frames and 2 boot frames with no retained MP3/ObjectDB warnings. In contrast, Godot 4.7.2 [push run 43570349587](https://github.com/Legioniz/LatchPoint/actions/runs/43570349587) and [PR run 43570448230](https://github.com/Legioniz/LatchPoint/actions/runs/43570448230) on `ci/branch-wide-godot-validation` both complete successfully but report two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 and `res://Project_bullshit.mp3` after each smoke-test process.
- **Latest evidence (2026-11-15):** Godot 4.7.2 [run 43687899303](https://github.com/Legioniz/LatchPoint/actions/runs/43687899303) on PR #12's feature/audio-import-sidecar-validation branch completed import, parse, physics and boot steps successfully, but the full log reports the same ObjectDB/MP3 resource-retention warnings after both smoke-test processes. The workflow also emits the Node.js 20 deprecation warning for actions/checkout@v4. The sidecar fix does not include PR #8's shutdown diagnostic.
- **Latest evidence (2026-11-18):** Godot 4.7.2 [branch-head run 44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467) on feature/high-speed-collision-regressions passes import, all tracked-GDScript parsing, physics smoke and boot smoke. Its physics process still reports two ObjectDB instances, one retained AudioStreamMP3/AudioStreamPlaybackMP3 for res://Project_bullshit.mp3, and an orphan Music StringName; the boot process passes without matching shutdown warnings. The log also emits the Node.js 20 deprecation warning for actions/checkout@v4.
- **Latest evidence (2026-11-19 review):** PR #14 [shared audio shutdown verifier](https://github.com/Legioniz/LatchPoint/pull/14), head 78f8097326607beaab4ad08dbc2a93ac0fb0fe14, is open/draft on top of PR #8's fix/audio-mix-cycle-boot-smoke-shutdown branch. Godot 4.7.2 push run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262) passed import, tracked-GDScript parsing, physics smoke and boot smoke. The complete 494-line log records the Dummy-driver mix reset after 12 physics process frames and 3 boot process frames at 44,100 Hz, with no ObjectDB/resource/MP3/StringName diagnostics or Godot ERROR/WARNING lines after either process. The only warning is the inherited Node.js 20 deprecation for actions/checkout@v4. This is clean downstream evidence, not an integrated main/PR #11/#12/#13 result; keep issue #3 open until the dependent stack is reconciled and retested.
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
- **Status:** In review on PR #7 and PR #13; broader coverage remains open.
- **Suggested role:** Gameplay QA / physics engineer.
- **Goal:** Increase deterministic regression coverage without treating generic probes as proof of every shipping-player interaction.
- **Evidence:** PR #7 checks that each enabled static platform in the current gameplay scene has a collision layer overlapping the real player's collision mask. PR #13 adds three test-only CharacterBody2D probes at 100 pixels per physics tick (6,000 pixels/second at the 60 Hz default) against 20-pixel-thick floor, wall and ceiling fixtures. The probes assert the expected collision classification and non-penetration; they do not exercise high-speed movement by the shipping player.
- **Likely files:** tests/physics_smoke_test.gd, tests/physics_probe.gd, possible test-only scenes.
- **Required remaining scenarios:** corners, slopes, one-way platforms, moving platforms, real-player high-speed movement, spawn/respawn overlap and frame-rate consistency. Add pickup, hazard, projectile and power-up interaction tests only when those mechanics exist.
- **Acceptance:** Each scenario has a reproducible setup, deterministic result and clear failure message; validate actual game objects where applicable, not only generic test probes.
- **Dependencies:** Confirm intended movement/collision rules before setting expected behavior.
- **PRs:** [#7](https://github.com/Legioniz/LatchPoint/pull/7) and [#13](https://github.com/Legioniz/LatchPoint/pull/13). PR #13 is based on feature/player-movement-regression-tests, not main.

### LP-INT-001 — Review and settle the dependent foundation PR chain

- **Priority:** P1
- **Status:** Integration advanced by PR #16, but the stack remains 96 commits ahead and 9 behind main; PR #1, the unrepresented movement-regression parent, and PR #11/#12/#13 dependencies remain unresolved.
- **Suggested role:** GitHub integration lead / senior reviewer.
- **Current repository evidence:** main remains at 097da44e4ad3fb2a3f1e762034855ef46cffdac4; its recursive tree has 72 entries and still contains no .github/workflows/, tests/ or shared project-management documents. The repository currently has 20 branch refs and 13 open draft PRs. Do not force-push or rewrite shared history.
- **Foundation blocker:** PR #1 targets main from feature/gameplay-foundation; GitHub reports mergeable=false / dirty, with 52 commits ahead and 9 behind. Main and PR #1 independently add README.md; reconcile that add/add conflict through a reviewed plan.
- **Unrepresented parent dependency:** PR #6 and PR #13 both target feature/player-movement-regression-tests. That branch is 25 commits ahead of feature/gameplay-foundation and has no PR using it as head. PR #13's feature/high-speed-collision-regressions head is 5 commits ahead of that parent; comparison with main reports 82 ahead and 9 behind. Recover/review the parent branch before advancing either dependent PR.
- **Unrepresented audio-shutdown experiment ref:** fix/audio-shutdown-grace-experiment remains four commits ahead of fix/windowed-borderless-toggle with no PR head. Preserve it as unreviewed historical/experimental work; do not treat it as a verified runtime fix or merge/delete it without explicit disposition.
- **Current PR relationships:**
  1. [PR #1 — gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1), base main, head feature/gameplay-foundation; dirty against current main.
  2. [PR #2 — fullscreen/window decoration fix](https://github.com/Legioniz/LatchPoint/pull/2), base feature/gameplay-foundation, head fix/windowed-borderless-toggle.
  3. [PR #4 — audio shutdown investigation docs](https://github.com/Legioniz/LatchPoint/pull/4), base fix/windowed-borderless-toggle, head docs/audio-shutdown-leak-investigation.
  4. [PR #5 — daily quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5), base feature/gameplay-foundation, head docs/daily-quality-management.
  5. [PR #6 — settings persistence](https://github.com/Legioniz/LatchPoint/pull/6), base feature/player-movement-regression-tests, head feature/settings-persistence.
  6. [PR #7 — platform collision-layer regression](https://github.com/Legioniz/LatchPoint/pull/7), base feature/settings-persistence, head feature/physics-layer-mask-regressions.
  7. [PR #8 — clean audio shutdown in both smoke-test processes](https://github.com/Legioniz/LatchPoint/pull/8), base feature/physics-layer-mask-regressions, head fix/audio-mix-cycle-boot-smoke-shutdown.
  8. [PR #9 — core-loop reference research](https://github.com/Legioniz/LatchPoint/pull/9), base docs/daily-quality-management, head docs/core-loop-reference-research.
  9. [PR #10 — daily QA audit](https://github.com/Legioniz/LatchPoint/pull/10), base docs/core-loop-reference-research, head quality/daily-audit-2026-11-13.
  10. [PR #11 — branch-wide CI validation](https://github.com/Legioniz/LatchPoint/pull/11), base feature/gameplay-foundation, head ci/branch-wide-godot-validation.
  11. [PR #12 — retained MP3 import-sidecar corrections](https://github.com/Legioniz/LatchPoint/pull/12), base feature/gameplay-foundation, head feature/audio-import-sidecar-validation.
  12. [PR #13 — high-speed collision regressions](https://github.com/Legioniz/LatchPoint/pull/13), base feature/player-movement-regression-tests, head feature/high-speed-collision-regressions; five files changed, 88 additions and 6 deletions.
  13. [PR #14 — shared audio shutdown verifier](https://github.com/Legioniz/LatchPoint/pull/14), base fix/audio-mix-cycle-boot-smoke-shutdown, head feature/shared-audio-shutdown-verifier; seven files changed, 170 additions and 93 deletions.
- **CI integration conflict:** PR #11 uses catch-all ** push/PR filters and pinned Node 24-compatible action commits on its own branch. The movement/physics/docs branches used by PR #13 and PR #14 still run actions/checkout@v4 and emit the Node.js 20 deprecation warning; their workflow copy is not the PR #11 version. Main still has no validation workflow.
- **Goal:** Preserve dependency order and ensure every PR's base/head SHA, complete diff, review state and checks are current.
- **Acceptance:** Reconcile PR #1 with current main without force-push; recover/review the movement-regression parent; preserve PR #11's workflow policy across descendants; integrate the audio fix with settings/physics; verify resource paths and full CI logs; merge only with explicit project-owner approval.
- **Do not:** Retarget or merge downstream PRs before their dependencies are settled.
- **Branch/PR:** Existing open draft PRs #1, #2 and #4–#13; this QA work continues on the existing quality branch / PR #10.

### LP-SEC-001 — Confirm repository visibility and protect main

- **Priority:** P1
- **Status:** Blocked on owner confirmation; no GitHub settings changed.
- **Problem/evidence:** Repository metadata currently reports `public`, while the project request describes it as private. The previous audit reported `main` and all inspected refs as unprotected; the current branch-protection endpoint returned HTTP 403 (`Resource not accessible by integration`), so this run could not re-verify current rules.
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
- **Status:** Blocked until the feature/test stack is reconciled; the current guide on PR #16 references runtime/test files absent from PR #10's documentation base.
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
- **Status:** Investigation complete; disposition recorded. No branch or file was changed. Owner confirmation is still required before archiving or deleting the historical ref.
- **Suggested role:** Repository steward / integration lead.
- **Evidence (2026-11-16):**
  - The repository has 18 branch refs. `automation/playability-baseline` points to `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`.
  - GitHub compare `main...automation/playability-baseline` reports `status=behind`, `ahead_by=0`, `behind_by=9`, with the same `f7bb59d9...` merge base. The automation ref has no unique commits relative to current main and is a historical ancestor.
  - All 11 PRs returned by the repository-wide all-state inventory were inspected. None uses `automation/playability-baseline` as its base or head. The commit is, however, the merge base of PR #1; preserve it as a comparison point while that PR remains unresolved.
  - The branch contains six root-level tracked Git-metadata-like files: `COMMIT_EDITMSG`, `FETCH_HEAD`, `HEAD`, `config`, `description` and binary `index`. The fetched text says: `COMMIT_EDITMSG` = `Initial commit`; `FETCH_HEAD` names the former Codfyyy/Latchpoint- remote; `HEAD` = `ref: refs/heads/main`; `config` points to that former remote and contains no credential in the inspected text; `description` is the generic placeholder. The binary index was confirmed present (200 base64 characters) but was not decoded.
  - Current main still tracks root `config`, `description` and binary `index`. Commit [9ce61c5](https://github.com/Legioniz/LatchPoint/commit/9ce61c5e014927aa3c90a14a0ea941e98823d42b) removed `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD` from main on 2026-11-11. PR #1 already proposes removing the remaining three root-level copies; do not duplicate that cleanup.
  - Official Git documentation locates active `HEAD`, `config` and `index` under `$GIT_DIR`; `git-fetch` writes `.git/FETCH_HEAD`, and `git-commit` uses `$GIT_DIR/COMMIT_EDITMSG`. The files at the project root are ordinary tracked blobs, not the GitHub-hosted repository's active metadata.
- **Disposition:** Retain `automation/playability-baseline` unchanged as a historical baseline/merge-base reference. Do not edit its tree, delete the branch, or decode/remove the binary index without owner direction. Preserve PR #1's existing cleanup proposal on its own branch.
- **Acceptance:** Every path has a documented disposition; no contributor branch, history or PR dependency is overwritten. **Met for this investigation.**
- **Remaining action:** Owner may explicitly authorize archiving/deleting the stale baseline ref later. No runtime change or cleanup commit is needed now.
- **Coordination:** Scope and file ownership were announced in a comment on [PR #10](https://github.com/Legioniz/LatchPoint/pull/10); this audit updates only the existing quality branch.
- **Branch/PR:** `quality/daily-audit-2026-11-13`, PR [#10](https://github.com/Legioniz/LatchPoint/pull/10).

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
- **Status:** Partial repository audit completed 2026-11-17; source/license confirmation remains owner-blocked.
- **Suggested role:** Audio integrator / asset librarian.
- **Goal:** Establish intended use, license and owner of `Tung.mp3`, `maj.mp3` and `yi.mp3`.
- **Evidence (2026-11-17):** The default-branch tree contains four root-level MP3 files. GitHub code search on `main` found `Project_bullshit.mp3` in `AUDIO.gd`; searches for `Tung.mp3`, `maj.mp3` and `yi.mp3` returned only their own `.import` sidecars. This is a default-branch search, not proof that no dynamic or branch-specific reference exists. All four files were added together in commit [8e586c1](https://github.com/Legioniz/LatchPoint/commit/8e586c1eb3c52f11b5c5167355e663587363d245) on 2026-08-23 by `Codfyyy` with the generic message “Add files via upload”; the commit provides no source, license or attribution. The current `LICENSE` expressly leaves third-party audio under its own terms and does not establish ownership of these files.
- **Related but separate:** Main's four `.import` sidecars point to `res://MUSIC/` although the files are at the project root. PR #1 and PR #12 correct those paths on unmerged branches; path repair does not resolve provenance or permission.
- **Acceptance:** Record references, intended use and license/source. Keep assets unless safely proven redundant and approved for deletion. Obtain owner/source confirmation before treating the files as redistributable project assets.

### LP-AUD-002 — Validate retained MP3 import sidecar source paths

- **Priority:** P2
- **Status:** In review on draft [PR #12](https://github.com/Legioniz/LatchPoint/pull/12); not integrated into main.
- **Problem/evidence:** On main, all four MP3 `.import` sidecars set `source_file` to `res://MUSIC/<filename>.mp3`, but the complete main tree has no `MUSIC/` directory and the four MP3 source files are at the repository root. PR #1 corrects `Project_bullshit.mp3.import`; PR #12 corrects `Tung.mp3.import`, `maj.mp3.import` and `yi.mp3.import`, and adds a deterministic check for all four retained sidecars.
- **Goal/player or project value:** Keep Godot's committed import metadata consistent with source-file locations and catch stale paths before runtime.
- **Scope:** Correct the three stale source paths and validate each expected sidecar path plus source-file existence.
- **Non-goals:** Do not change audio playback/shutdown behavior, imported destination paths, UIDs, import parameters, MP3 binaries or licensing claims.
- **Likely files:** Tung.mp3.import, maj.mp3.import, yi.mp3.import, tests/physics_smoke_test.gd, and the PR's existing documentation updates.
- **Dependencies/conflicts:** Based on feature/gameplay-foundation; coordinate with PR #8's separate audio-lifecycle work. Do not edit either active branch from this QA task.
- **Suggested role:** Godot asset/import QA.
- **Acceptance criteria:** Each sidecar loads as ConfigFile, its deps/source_file equals the correct root-level res://... path, and the referenced file exists. Preserve all other sidecar fields and binaries.
- **Required tests/proof:** Godot 4.7.2 headless import, tracked GDScript parse, physics smoke test (including four-sidecar assertions), and complete log inspection. The latest [run 43687899303](https://github.com/Legioniz/LatchPoint/actions/runs/43687899303) passed process steps but still reproduced issue #3.
- **Branch/PR:** feature/audio-import-sidecar-validation, draft [PR #12](https://github.com/Legioniz/LatchPoint/pull/12).
- **Issue register:** LP-IMP-001.

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

## 2026-11-20 — LP-INT-001 / LP-QA-001 handoff

- **PR #14:** `feature/shared-audio-shutdown-verifier` at `78f8097326607beaab4ad08dbc2a93ac0fb0fe14`, based on `fix/audio-mix-cycle-boot-smoke-shutdown`. Full Godot 4.7.2 run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262) shows the shared verifier observing the mix reset after 12 process frames and no matching shutdown diagnostics in either smoke process.
- **PR #15:** `feature/settings-exit-flush-regression` at `6a028594205c408f0e885e81bca26bb035cc7d46`, based on `feature/settings-persistence`. The new debounce/exit-tree persistence assertions pass in run [44478777582](https://github.com/Legioniz/LatchPoint/actions/runs/44478777582), but its physics smoke test still uses a fixed two-frame audio shutdown wait and reproduces issue #3 diagnostics.
- Both PR heads have identical production `AUDIO.gd` blob SHA `bbfc914556569a979a71c3a313cb4fbb97829509`. GitHub compare reports PR #15 is 2 ahead / 9 behind PR #14 from merge base `43eee75ba3d912142b1eccbdd7629a8448f180c4`.
- **Decision:** do not retarget or rewrite either contributor branch. After dependency review, coordinate the settings test changes with the shared verifier on a single integration head and re-run the complete Godot workflow. Keep issue #3 open until that combined run is clean.
- No runtime implementation, branch mutation or merge was performed in this audit. The project-owner core-loop decision remains P0 and unresolved.


## 2026-11-21 — PR #16 combined verification handoff

- **LP-QA-001:** The Settings exit-tree regression and shared audio shutdown verifier now pass together on [PR #16](https://github.com/Legioniz/LatchPoint/pull/16), head `481f62d5d3bbc13c3324b110bc1510ab451e2136`. Final Godot 4.7.2 run [44689799965](https://github.com/Legioniz/LatchPoint/actions/runs/44689799965) observed mix resets after 9 physics frames and 12 boot frames at 44,100 Hz, with no matching ObjectDB/MP3/StringName shutdown diagnostics. **Status:** clean on this downstream head; issue #3 remains open until the stack reaches main and a main-based run is clean.
- **LP-INT-001:** PR #16 is open/draft and mergeable, based on PR #14's head and preserving PR #15 as its second parent. It is 96 commits ahead and 9 behind main. PR #11's Node 24-pinned workflow, PR #12's remaining MP3 sidecar corrections and PR #13's high-speed probes are not included. PR #1 remains dirty/non-mergeable; the movement-regression parent remains unrepresented. **Status:** integration advanced, still blocked from main by the dependency stack.
- **LP-DOC-002:** The current testing guide exists on PR #16 but is not yet compatible with PR #10's documentation base because that base lacks `Settings.gd` and `tests/audio_shutdown_verifier.gd`. **Status:** blocked until the feature/test stack is reconciled; do not copy a guide whose commands do not match the target tree.
- **LP-SEC-001:** GitHub's latest branch listing reports `main.protected=false`; repository metadata reports public visibility. No settings were changed. Owner confirmation and authorization remain required.
- **Repository inventory:** 22 branch refs, 15 open draft PRs, one open issue (#3). Main remains at `097da44e4ad3fb2a3f1e762034855ef46cffdac4` with 72 tree entries.
- **Coordination:** review PR #16 and issue #3 with the final-head CI evidence. No contributor branch was rewritten, retargeted or merged; main was not modified.
