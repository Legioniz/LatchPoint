# Improvement Log

Each completed cycle records its purpose, affected files, sources, verification evidence, remaining risks and PR/commit link. Unrun tests are explicitly marked as unverified.

## 2026-11-09 — Foundation and integration repair (PR #1)

**Goal:** make the existing 2D prototype more internally consistent, remove broken references and establish an accountable development process.

### Gameplay and menus
- Reworked `Scene/player.gd` so one horizontal velocity calculation applies acceleration and friction consistently; speed, acceleration, friction and jump velocity are configurable.
- Routed New Game in `new_load.gd` to `res://Scene/main.tscn`.
- Disabled Load Game until a real save system is available.
- Replaced the placeholder title with LATCHPOINT.
- Attached the pause menu to the gameplay scene and centralized pause/resume/return/quit callbacks.
- Removed missing/unused pause button script dependencies.

### Audio and settings
- Corrected the autoload music path from a nonexistent `res://MUSIC/` folder to the MP3's committed root location.
- Corrected the MP3 import sidecar source path.
- Connected the music slider to the autoload's in-memory volume state so scene changes do not reset its value.
- Made the fullscreen toggle reflect fullscreen versus windowed mode.

### Missing resources and repository hygiene
- Replaced the absent `bg/game_background_4/game_background_4.png` reference with a temporary built-in color background. Final art remains a backlog item.
- Removed committed Git-internal files (`HEAD`, `config`, `index`, `FETCH_HEAD`, `COMMIT_EDITMSG`, `description`).
- Removed confirmed unreferenced empty prototype files (`control.tscn`, `LP.tscn`, `node_2d.tscn`, `main_menu.gd`, `menu.gd`) and their UID sidecars where present.
- Removed redundant button scripts after their handlers were consolidated into the owning menu controller.

### Research and process
- Added this playbook, backlog, research register and project README.
- Added a headless scene/physics smoke test and GitHub Actions validation workflow.
- Updated the recurring development instructions to require multi-source research, dependency inspection, physics/collision testing, CI log review, file-purpose auditing, and truthful ML/agent testing.

### Verification status
- Repository structure and affected scripts/scenes/resources were inspected through the GitHub connector.
- Godot runtime is not installed in the current editing environment. The project has **not** yet been executed locally here.
- The newly added CI workflow is intended to perform Godot 4.7.2 import, scene boot and deterministic floor-collision checks. Its result must be read from GitHub Actions before this PR is considered verified.
- No ML model was trained or executed. The playbook defines ML-assisted exploration as a future, conditional test strategy; it is not represented as completed work.

**PR:** https://github.com/Legioniz/LatchPoint/pull/1

## 2026-11-13 — Core-loop reference comparison and backlog synchronization

**Objective:** complete the research-agent portion of LP-DES-001 without inventing LatchPoint's product direction. The product-owner decision remains blocked.

### Research completed
- Compared three distinct player-experience patterns: authored course surprise in *Super Mario Bros. Wonder*, precision movement forgiveness in *Celeste*, and compact open exploration in *A Short Hike*.
- Reviewed Nintendo's official developer interview, Maddy Thorson's developer-authored *Celeste* notes, Adam Robinson-Yu's GDC 2020 postmortem and the official *A Short Hike* description.
- Rechecked Godot 4.7's CharacterBody2D guide and the MIT-licensed Godot demo-project repository as technical references.
- Recorded scale/context, observations, LatchPoint relevance, trade-offs, licensing/IP notes and a neutral prototype-evaluation method in `RESEARCH_REGISTER.md`.
- No game, level, mechanic, art, audio, code or text was copied.

### Findings and decision
- The references represent different loops, not interchangeable feature lists.
- The current prototype has a CharacterBody2D, basic left/right/jump controls and static platforms, but no approved goal, fail state, reward loop, progression or signature mechanic.
- The evidence does not justify selecting a course-based, precision-challenge, exploration or title-implied latching direction.
- Recommended next design step: obtain the product owner's direction, then greybox one short slice around one repeated action, clear feedback, a goal/reward and a next decision. Proposed playtest questions are documented; no player test or metric was collected.

### Repository-state synchronization
- Updated `BOT_TASK_BOARD.md` to record that the core-loop research is prepared but the owner decision is still pending, and to reflect the current downstream PR work.
- Updated `IMPROVEMENT_BACKLOG.md` to distinguish implementation verified on open downstream branches from work already integrated into `main`.
- Recorded PR #6 settings persistence, PR #7 platform layer/mask coverage and PR #8 audio shutdown verification as downstream work, not as changes already present on `main`.
- Current default-branch HEAD at inspection: `cc7b304d9636353c5de1a056955bd24168a4906c`.
- PR #1 remains open/draft and GitHub reports it as not mergeable. Comparing its base to `main` showed the branch 52 commits ahead and 5 behind, with the merge base at `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`. Reconcile this integration state before merging any downstream work.
- PR #6 uses `feature/player-movement-regression-tests` as its base. That branch is 25 commits ahead of `feature/gameplay-foundation`, and no open or closed PR with that branch as its head appeared in the current PR listing. Recover/review this parent integration path before merging PR #6 or its descendants.
- Workflow variants are inconsistent: the foundation/docs branches push only on `main` and `feature/**`, while the inspected movement/settings/physics/audio descendants also include `fix/**`. None of the inspected versions includes `docs/**`, and all restrict pull-request events to `main`. Docs branches are not push-triggered, and stacked PRs targeting non-main branches do not receive pull-request-triggered checks. PR #8's fix-prefixed head is push-eligible under its own branch's workflow; run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) passed, but its event type was not available in the retrieved job details.
- PR #8's Godot 4.7.2 workflow run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) completed successfully. The job log includes successful physics and boot smoke-test messages; the extracted log contains no matching ObjectDB/MP3 shutdown warning lines. Issue #3 remains open until the dependent change is integrated.

### Verification and limitations
- Documentation-only changes: `RESEARCH_REGISTER.md`, `IMPROVEMENT_BACKLOG.md`, `IMPROVEMENT_LOG.md` and `BOT_TASK_BOARD.md`.
- No GDScript, scenes, project settings, assets or runtime architecture changed.
- No Godot runtime, import, parser, physics or manual gameplay tests were run for this documentation-only cycle.
- The current workflow's push filter does not include `docs/**`, and its pull-request filter targets `main`; no CI run is expected for this docs branch/stack.
- No performance profiling or ML was performed.

**Branch:** `docs/core-loop-reference-research` (based on `docs/daily-quality-management`). **Draft PR:** [#9](https://github.com/Legioniz/LatchPoint/pull/9), open and mergeable at last inspection; review/integration pending.


## 2026-11-16 — Legacy Git metadata disposition audit

**Objective:** complete LP-REPO-001 by determining whether the unassociated `automation/playability-baseline` ref can be safely cleaned up without destroying historical or contributor work.

### Findings
- The ref points to `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`; comparison with current `main` reports zero commits ahead and nine behind. It is the merge base of PR #1 and has no unique commits relative to main.
- None of the 11 current PRs uses this branch as base or head.
- Its root tree contains tracked `COMMIT_EDITMSG`, `FETCH_HEAD`, `HEAD`, `config`, `description` and binary `index` files. The text config contains the former repository URL but no credential in the inspected content. The binary index was not decoded.
- Main's commit [9ce61c5](https://github.com/Legioniz/LatchPoint/commit/9ce61c5e014927aa3c90a14a0ea941e98823d42b) already removed `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD`; PR #1 proposes removing `config`, `description` and `index` from the foundation tree.
- Git's official layout documentation confirms that active metadata lives under `$GIT_DIR`; the root-level copies are tracked project blobs and do not configure the hosted repository.

### Decision
- Preserve the automation branch unchanged as a historical baseline and PR #1 merge-base reference.
- Do not delete the branch, edit its metadata, or duplicate PR #1 cleanup without owner direction.
- Recorded the disposition in the task board, issue register, research register and daily QA log. Posted a coordination comment on PR #10 before editing the existing quality branch.

### Verification and limitations
- Documentation-only; no Godot import/parser/scene/physics/audio/desktop/export test was relevant or run.
- Re-fetched and reviewed the five updated Markdown files after committing.
- No runtime code, scenes, assets, project settings, workflows, UIDs, import sidecars or other contributor branches changed. No branch was created/deleted and no PR was merged.
- No performance measurements or ML experiments were performed.

**Branch:** `quality/daily-audit-2026-11-13`  
**PR:** [#10](https://github.com/Legioniz/LatchPoint/pull/10), existing draft PR extended with this audit.


## 2026-11-17 — MP3 asset provenance audit (LP-AUD-001)

**Objective:** make a bounded, non-destructive assessment of the retained audio files because the project license explicitly separates owner materials from third-party audio.

### Findings
- The 72-entry default-branch tree contains four root-level MP3s and four matching import sidecars.
- Default-branch code search found `Project_bullshit.mp3` in `AUDIO.gd`; `Tung.mp3`, `maj.mp3` and `yi.mp3` appeared only in their own import sidecars. This is not a complete all-branch or dynamic-loader audit.
- All four assets were added in one commit on 2026-08-23 by account `Codfyyy`, with message “Add files via upload”; no source, license or attribution was supplied in the commit metadata.
- The current proprietary license does not establish rights in third-party audio. The sidecar path repair in PR #1 / PR #12 is separate from provenance.

### Research and decision
- Rechecked the Godot 4.7 Import Process documentation: source assets and companion `.import` configuration should remain in version control; generated `.godot/imported/` data is a local cache.
- No external game, source code, sound or asset was copied. No gameplay reference research was needed for this repository-provenance task.
- Preserve all MP3 binaries, UIDs and sidecars. Ask the asset owner to confirm source, rights holder, license/permission and intended use before any redistribution or removal.

### Verification and limitations
- Read the main tree, audio autoload, project configuration, LICENSE/COPYRIGHT, all four main sidecars, the upload commit metadata, default-branch code-search results and the PR #12 corrected sidecars.
- Confirmed PR #12 changes the three stale `source_file` values to root-level paths; its CI does not resolve rights or intended use.
- No code, scenes, assets, UIDs, import sidecars, project settings or workflows changed. No files were deleted or moved.
- No local Godot executable/editor was available. No local import, parser, scene, physics, playback, desktop, export or performance test was run. CI was reviewed separately; no new CI run was triggered by this documentation-only update.
- No ML/agent test was justified or performed. No performance measurements were available.

**Branch:** `quality/daily-audit-2026-11-13` (existing quality branch). **PR:** [#10](https://github.com/Legioniz/LatchPoint/pull/10), existing draft PR; no new PR created.
