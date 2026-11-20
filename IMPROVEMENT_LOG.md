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


## 2026-11-18 — High-speed collision and integration QA

**Objective:** review the new high-speed collision regression branch, refresh the shared backlog/issue/task records, and revalidate the integration dependencies. No gameplay direction was inferred because LP-DES-001 remains blocked on product-owner approval.

### Review findings
- Reviewed draft [PR #13](https://github.com/Legioniz/LatchPoint/pull/13), head 066cdded1486072e229ae52449b3ca858211912e, base feature/player-movement-regression-tests. It changes only tests/physics_smoke_test.gd and four existing Markdown documents; no shipping player script, scene, asset, project setting, collision shape, input map or dependency changes.
- The test uses a synthetic CharacterBody2D probe, derives speed from the configured physics tick rate, and checks floor/wall/ceiling contact plus non-penetration at 100 pixels per tick against 20-pixel-thick fixtures. It does not test high-speed movement of the shipping player.
- The movement-regression parent remains unrepresented by a PR and is 25 commits ahead of feature/gameplay-foundation. PR #13 is stacked on that parent; its head compares to main as 82 commits ahead and 9 behind. PR #1 remains 52 ahead and 9 behind main and GitHub reports it non-mergeable/dirty.

### Research and licensing
- The PR's research register cites the Godot 4.7 CharacterBody2D guide and the official Godot demo-project Kinematic Character 2D sample (MIT). The demo was used as a technical reference only; no code or assets were copied.
- A commercial/indie gameplay comparison was not applicable to this engine-level test-only change. No new dependencies or license obligations were introduced.

### Verification
- Inspected PR #13's complete diff, changed-file list, test helper and test implementation, PR metadata, branch comparison and full 489-line Godot 4.7.2 job log.
- [Run 44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467), job 133876376770, completed resource import, all tracked-GDScript parse checks, the physics smoke test and the boot smoke test successfully. The physics log confirms the normal-speed and high-speed floor/wall/ceiling assertions.
- The physics process still reports two leaked ObjectDB instances, one resource in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 for res://Project_bullshit.mp3, and an orphan Music StringName. The boot process passes without matching shutdown warnings. The log also reports the Node.js 20 deprecation warning for actions/checkout@v4. Issue #3 remains open.
- No local Godot executable/editor was available; no local import, parser, scene, physics or desktop test was run. Manual visible-collision verification was not performed.
- No ML/agent evaluation was justified or performed. No performance profiling or measurements were available.

### Scope and handoff
- Updated IMPROVEMENT_BACKLOG.md, BOT_TASK_BOARD.md, ISSUE_REGISTER.md, RESEARCH_REGISTER.md, IMPROVEMENT_LOG.md and DAILY_QA_LOG.md on the existing quality branch. No GDScript, scene, asset, UID, import sidecar, project setting, workflow or architecture file was changed. No files were created or deleted.
- No branch was created/deleted, no PR was merged or retargeted, and no repository settings were changed. The existing PR #10 stack was preserved; its base remains docs/core-loop-reference-research.
- Next: recover/review the unrepresented movement-regression parent, reconcile PR #1's README add/add conflict, then integrate the settings/physics/audio/high-speed test stack in dependency order while preserving PR #11's catch-all CI workflow. Do not add gameplay systems until LP-DES-001 is approved.


## 2026-11-19 — Shared audio shutdown verifier and integration QA

**Objective:** review the latest shared audio-shutdown test refactor, verify its Godot 4.7.2 evidence, and synchronize integration records. This is a test-infrastructure/documentation cycle; no gameplay direction was inferred and no production audio behavior was changed.

### Repository and branch review
- Main remains at 097da44e4ad3fb2a3f1e762034855ef46cffdac4, with 72 tree entries and no .github/workflows/, tests/, or shared improvement/architecture documents.
- Current GitHub inventory: 20 branch refs, 13 open draft PRs, and open issue #3. PR #14 is open/draft and mergeable; base fix/audio-mix-cycle-boot-smoke-shutdown at 31ada925876e611b02b6ec2f6830cf5f7b932a27, head feature/shared-audio-shutdown-verifier at 78f8097326607beaab4ad08dbc2a93ac0fb0fe14.
- The main-branch protection endpoint again returned HTTP 403 (Resource not accessible by integration). Protection rules could not be verified; no repository settings were changed.

### PR #14 implementation review
- Reviewed all seven changed files and the helper, both smoke-test entrypoints, AUDIO.gd, Settings.gd, project.godot, default_bus_layout.tres and the inherited validation workflow.
- PR #14 adds a test-only RefCounted helper. It validates the Audio autoload/player, calls the existing shutdown_audio(), checks the player is stopped and its stream is cleared, observes an AudioServer mix-age reset within 120 process frames, then waits two additional process frames for deferred cleanup.
- The physics smoke test still requires active background playback before shutdown; the boot test intentionally does not. Each CI command remains a separate Godot process and invokes the helper independently.
- Production AUDIO.gd, scenes, assets, project settings, audio buses, gameplay scripts and dependencies are unchanged by PR #14. The helper timing diagnostic is not by itself proof that all engine references are released; complete process logs remain part of acceptance. No blocking defect was identified.

### Research and licensing
- Rechecked Godot 4.7 AudioServer, SceneTree and GDScript documentation for mix-time queries, the process_frame signal and await; details are recorded in RESEARCH_REGISTER.md.
- This test-infrastructure refactor does not benefit from a commercial/indie game comparison. No external code, audio, art, scenes or other assets were copied, and no new dependency or license obligation was introduced.

### Verification
- Godot 4.7.2 run 44255399262, job 134635783821, completed checkout, engine install/version, resource import, every tracked-GDScript parse, physics smoke and main-scene boot.
- The complete 494-line log reports Dummy audio at 44,100 Hz. Physics observed a mix reset after 12 process frames (initial next-mix estimate 0.0793 s); boot observed one after 3 process frames (initial estimate 0.0168 s). No ObjectDB/resource/MP3/StringName retention diagnostics or Godot ERROR/WARNING lines follow either process. The only warning is the Node.js 20 deprecation notice for actions/checkout@v4.
- Earlier push run 44255209541 also passed all validation steps; the physics process observed its mix reset after 9 process frames.
- Local Godot 4.7.2 execution was unavailable. No local import, parser, scene-load, physics, visible-collision, native desktop audio, export or manual gameplay test was performed.
- Latest physics output confirms the current player landed, movement regression checks held, platform collision layers matched the player mask, and floor/wall/ceiling checks held on this branch. PR #13 synthetic high-speed probes are on a sibling branch and are not included in this run. Corners, slopes, one-way/moving platforms, actual-player high-speed movement, spawn/respawn overlap and frame-rate variation remain unverified.
- ML/agents: none justified or performed. Performance: no profiler or target-hardware measurements were available; no optimization was attempted.

### Scope, changes and handoff
- Updated six existing project-management documents on the existing quality branch. No files were created or deleted; no GDScript, scene, resource, asset, UID, import sidecar, project setting, workflow, autoload or architecture file was changed.
- No contributor feature branch was modified, no PR was merged or retargeted, and main was not changed. Existing PR #10's stacked base was preserved; a new main-target PR would duplicate or pull in unresolved documentation/foundation dependencies.
- Rollback is a single revert of this documentation-only commit; no runtime state or project behavior is affected.
- Issue #3 remains open until the clean helper is integrated with the sidecar and CI changes and a fresh integrated Godot 4.7.2 run confirms both complete process logs.
- Next: reconcile PR #1's README add/add conflict and recover/review the unrepresented movement-regression parent; then coordinate PR #8/#14 with PR #11/#12/#13 in dependency order. Keep LP-DES-001 blocked until the product owner confirms the player promise, loop, win/fail states and design pillars.

## 2026-11-20 — Cross-branch audio shutdown regression comparison (LP-QA-001 / issue #3)

**Objective:** determine why the settings-lifecycle branch still reports retained MP3 resources while the shared audio-shutdown verifier branch has clean process logs. Avoid changing production audio code until the difference is isolated.

### Repository and branch evidence
- Default branch remains `main` at `097da44e4ad3fb2a3f1e762034855ef46cffdac4`; it has not advanced since 2026-11-13. Main still lacks the downstream test suite and validation workflow.
- PR #14 head: `feature/shared-audio-shutdown-verifier` at `78f8097326607beaab4ad08dbc2a93ac0fb0fe14`; base: `fix/audio-mix-cycle-boot-smoke-shutdown`.
- PR #15 head: `feature/settings-exit-flush-regression` at `6a028594205c408f0e885e81bca26bb035cc7d46`; base: `feature/settings-persistence`.
- GitHub compare reports the two heads diverged: PR #15 head is 2 commits ahead and 9 behind PR #14, with merge base `43eee75ba3d912142b1eccbdd7629a8448f180c4`.

### Controlled source comparison
- `AUDIO.gd` has the exact same blob SHA on both branches: `bbfc914556569a979a71c3a313cb4fbb97829509`. No production audio-script difference explains the different shutdown output.
- PR #14's `tests/physics_smoke_test.gd` uses `tests/audio_shutdown_verifier.gd`: stop/clear the player, wait for an observable AudioServer mix-age reset (bounded at 120 process frames), then wait two deferred-cleanup frames.
- PR #15's physics smoke test calls `shutdown_audio()` directly and waits only two `process_frame` signals. Its boot test runs 120 frames before shutdown, so the two-frame wait occurs after a much longer playback/mix interval.

### Full CI log evidence
- PR #14 run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262), job 134635783821: 494-line Godot 4.7.2 log. The helper reports Dummy driver, 44,100 Hz and a mix reset after 12 process frames. No matching ObjectDB/resource/MP3/StringName shutdown diagnostics appear in either smoke process.
- PR #15 run [44478777582](https://github.com/Legioniz/LatchPoint/actions/runs/44478777582), job 135405652408: 498-line Godot 4.7.2 log. The physics process reports 2 leaked ObjectDB instances, 1 resource still in use, retained AudioStreamPlaybackMP3 and AudioStreamMP3 for `res://Project_bullshit.mp3`, and an unclaimed `Music` StringName. The boot process has no matching retained-resource diagnostics.
- All workflow steps in both runs completed successfully. A successful exit code is not treated as proof of clean shutdown.

### Interpretation and decision
- Evidence strongly supports insufficient mix/deferred-cleanup waiting in the PR #15 physics test harness as the immediate differentiator. The same production `AUDIO.gd` with the shared mix-cycle verifier has a clean log; the two-frame-only physics path reproduces the warnings.
- This does not prove the precise engine-internal lifecycle cause, establish an upstream Godot defect, or prove the settings change caused the warning.
- Keep issue #3 open until the settings-lifecycle regression and shared verifier are exercised together on one reviewed integrated head. Do not suppress diagnostics or change production audio ownership based on the current evidence.
- Posted a detailed evidence/handoff comment on [issue #3](https://github.com/Legioniz/LatchPoint/issues/3#issuecomment-7027119636).

### Scope, tests and limitations
- Read-only inspection of repository metadata, branches, PRs, file blobs, branch comparison and full GitHub Actions job logs; no source or asset changes.
- Local Godot import/parser/scene/physics/audio tests were not run because Godot is unavailable in the editing environment. No manual desktop audio test was performed.
- No gameplay physics changed; slopes, one-way/moving platforms, corners and real-player high-speed movement were not newly tested.
- No ML/agent evaluation was justified or performed. No performance measurements were available; no optimization was attempted.
- No files were created or removed. No contributor branch was rewritten, retargeted, force-pushed or merged; main remains untouched.

**Next:** coordinate PR #15's boot test with the shared verifier from PR #14 after dependency review, then run both smoke processes and inspect the complete logs on the combined head.
