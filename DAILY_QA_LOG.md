# Daily QA Log

## 2026-11-13 — Repository structure, integration and CI audit

**Role:** Project quality manager / repository steward  
**Repository:** [Legioniz/LatchPoint](https://github.com/Legioniz/LatchPoint)  
**Engine target:** Godot 4.7.x  
**Audit scope:** complete main tree and all 15 branch refs, open PRs and their dependency relationships, recent commits, issue #3, CI workflow filters, latest workflow runs and the full latest successful job log.

### Overall project health

**Status: Needs attention.** The default branch is still the older prototype state and contains confirmed missing resource paths and incomplete player movement logic. The foundation and downstream fixes are staged in draft PRs and have not reached main. A later Godot 4.7.2 CI run on the audio-fix branch passed the import, parse, physics and boot checks, including clean audio shutdown diagnostics, but that result does not make main healthy or resolve the integration blockers.

### Repository and branch inventory

- Repository metadata confirms default branch `main`, public visibility, and current main HEAD `cc7b304d9636353c5de1a056955bd24168a4906c` (2026-11-11 14:27:42 UTC).
- Inspected the complete, non-truncated recursive tree on main (71 entries) and the complete tree for every other listed branch ref.
- Branch refs inspected:
  - `main` — `cc7b304d9636353c5de1a056955bd24168a4906c`
  - `automation/playability-baseline` — `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`
  - `docs/audio-shutdown-leak-investigation` — `5fb8316add5713907c491aa3b5b8c150436aee43`
  - `docs/core-loop-reference-research` — `24b7de76a920997f46ad454aae996cd2f1f308f8`
  - `docs/daily-quality-management` — `9d4bb00d34956c81f8f44df8c342a54f23ae2367`
  - `feature/audio-shutdown-cleanup` and `feature/gameplay-foundation` — both point to `58310c34342eed3bbe7b80cf3e2c9fd253acb566`
  - `feature/physics-layer-mask-regressions` — `c1a0c6e6115a49866cc9b9421642401cb1bbed63`
  - `feature/player-movement-regression-tests` — `93b0960fca99e760af550efdb7cb34a0ce6ef465`
  - `feature/settings-persistence` — `43eee75ba3d912142b1eccbdd7629a8448f180c4`
  - `fix/audio-mix-cycle-boot-smoke-shutdown` — `31ada925876e611b02b6ec2f6830cf5f7b932a27`
  - `fix/audio-mix-cycle-shutdown` — `8226be2bf3b2fdef2412a8e3207a4e90889db4d7`
  - `fix/audio-server-shutdown-grace` and `fix/windowed-borderless-toggle` — both point to `ae7c8de03b6502d3b38fa1c481fb6fdf89df6f62`
  - `fix/audio-shutdown-grace-experiment` — `b0a7fca59f9515b083cfaae9bbe22e27e6fc701b`
- The duplicate-head branch names may be aliases or historical working refs. No branch was deleted or modified; inspect references and contributor intent before any cleanup.
- Branches without a corresponding current PR head include the baseline/experiment refs and `feature/player-movement-regression-tests`. Do not infer that they are abandoned or safe to delete.
- All currently listed open PRs are draft and authored by Legioniz. The inspected PR timelines/review summaries contain no review comments or submitted reviews. No bot identity or assignment was confirmed.
- Recent main commits include the project overview/setup README update, project description update, and partial copied-Git-metadata cleanup. Older baseline history includes commits by Codfyyy.

### Pull requests and integration dependencies

All listed PRs remain open/draft; no merge or retarget action was taken:

1. [PR #1 — gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1): `main` ← `feature/gameplay-foundation`. GitHub reports `mergeable=false`. The PR's recorded base SHA is `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`, while current main is `cc7b304d9636353c5de1a056955bd24168a4906c`. Compare reports **52 commits ahead, 5 behind**, with merge base `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`. The PR changes 40 files. Do not merge, force-push, or rewrite the branch; reconcile the five newer main commits through a reviewed, non-destructive update first.
2. [PR #2 — fullscreen/window-decoration fix](https://github.com/Legioniz/LatchPoint/pull/2): `feature/gameplay-foundation` ← `fix/windowed-borderless-toggle`.
3. [PR #4 — audio shutdown investigation docs](https://github.com/Legioniz/LatchPoint/pull/4): `fix/windowed-borderless-toggle` ← `docs/audio-shutdown-leak-investigation`.
4. [PR #5 — daily quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5): `feature/gameplay-foundation` ← `docs/daily-quality-management`.
5. [PR #6 — settings persistence](https://github.com/Legioniz/LatchPoint/pull/6): `feature/player-movement-regression-tests` ← `feature/settings-persistence`.
6. [PR #7 — platform collision-layer regression](https://github.com/Legioniz/LatchPoint/pull/7): `feature/settings-persistence` ← `feature/physics-layer-mask-regressions`.
7. [PR #8 — audio shutdown verification in both smoke-test processes](https://github.com/Legioniz/LatchPoint/pull/8): `feature/physics-layer-mask-regressions` ← `fix/audio-mix-cycle-boot-smoke-shutdown`.
8. [PR #9 — core-loop reference research and task tracking](https://github.com/Legioniz/LatchPoint/pull/9): `docs/daily-quality-management` ← `docs/core-loop-reference-research`. GitHub reports this PR as mergeable; it changes four Markdown files and is 14 commits ahead, 0 behind its parent.

**Missing parent review path:** PR #6 is based on `feature/player-movement-regression-tests`, which is 25 commits ahead of `feature/gameplay-foundation`; no PR with that branch as its head appeared in the all-state PR inventory. Recover/review that branch's intended integration path before integrating PR #6 or descendants. Do not silently skip its commits.

### Main-branch file and Godot integrity findings

- Main's `project.godot` targets Godot 4.7 / Forward Plus. Its main-scene UID matches `menu.tscn`; its Audio autoload UID matches the tracked `AUDIO.gd.uid` sidecar.
- **Confirmed missing scene resource:** `Scene/main.tscn` references `res://bg/game_background_4/game_background_4.png`, but no `bg/` path exists in the complete main tree.
- **Confirmed audio path mismatch:** main's `AUDIO.gd` loads `res://MUSIC/Project_bullshit.mp3`, while the tracked MP3 and its import sidecar are at the repository root. No `MUSIC/` directory exists in main.
- **Confirmed movement logic defect:** main's `Scene/player.gd` first calculates acceleration/friction-based horizontal velocity, then overwrites `velocity.x` with a second direct movement/deceleration calculation later in the same physics callback.
- The foundation PR changes the background to a built-in ColorRect, corrects the music path, integrates the pause menu, consolidates the player movement calculation, and adds headless tests. These changes remain staged, not integrated into main.
- Main's root still contains `config`, `description` and `index`. The `config` content is a copied Git configuration containing an old origin URL for `Codfyyy/Latchpoint-`; `description` is the default Git repository description; `index` is binary Git index data and could not be decoded as UTF-8. Commit [9ce61c5](https://github.com/Legioniz/LatchPoint/commit/9ce61c5e014927aa3c90a14a0ea941e98823d42b) removed `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD`, but left these three files. PR #1 already deletes `config`, `description` and `index`; do not create a duplicate cleanup or delete them directly from main.
- Main's root contains no `.github/workflows/`, `tests/`, or shared project-management documents. Those are present on the staged foundation/docs branches, not on main.
- `.gitignore` ignores `.godot/`, `/android/`, common OS files and `*.log`; `.gitattributes` normalizes text files to LF. No generated cache, export directory, temporary log or obvious secret file appeared in the inspected main tree. No export preset was present.
- Existing `Asset/` and `Scene/` capitalization and root-level scripts are established project paths. No broad relocation is justified while the PR stack is unsettled.
- Four MP3 assets have tracked import sidecars. The corrected Audio autoload references `Project_bullshit.mp3`; the intended use and licensing of `Tung.mp3`, `maj.mp3` and `yi.mp3` remain unconfirmed. Preserve them pending investigation.
- The documentation branch includes the requested agent/charter/architecture/file-structure/task/issue/backlog/daily-log/testing/research documents. PR #9 updates the task board, backlog, improvement log and research register; its research comparison does not select a genre or core mechanic.

### CI, logs and verification evidence

- Inspected the latest ten workflow-run summaries and the full 490-line job log for [Godot validation run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644).
- Run 43175060644 completed successfully on 2026-11-12. It was a **push** event on `fix/audio-mix-cycle-boot-smoke-shutdown`, commit `31ada925876e611b02b6ec2f6830cf5f7b932a27`, using **Godot 4.7.2**.
- The job's setup, checkout, engine-version, resource-import, tracked-GDScript parse, physics smoke-test and boot-test steps all completed successfully.
- Inspected log output includes:
  - `Audio shutdown diagnostic passed` on the physics process after an observed mix reset in 11 process frames.
  - `LatchPoint tests passed` with scene loading, player landing/movement, platform-layer/player-mask and floor/wall/ceiling checks.
  - `Boot-test audio shutdown passed` after an observed mix reset in 2 process frames.
  - `LatchPoint boot test passed` for menu loading, settings persistence, windowed-decoration flag restoration and frame-loop completion.
- No `ObjectDB`, retained MP3 playback, `resources still in use`, Godot `ERROR:` or Godot `WARNING:` lines matched in that run's full job log. The remaining logged warning is GitHub Actions' Node.js 20 deprecation notice for `actions/checkout@v4`; it did not fail the job.
- [Issue #3](https://github.com/Legioniz/LatchPoint/issues/3) remains open until the PR #8 dependency stack is integrated and the resulting integrated head is revalidated. The clean branch run is evidence for PR #8's head, not for main.
- **CI trigger gap confirmed from workflow files:** foundation/docs workflow variants push only on `main` and `feature/**`; downstream movement/settings/physics/audio variants also include `fix/**`. All inspected variants restrict `pull_request` events to base `main`, and none includes `docs/**` in push filters. Thus docs branches do not receive push-triggered validation, and stacked PRs targeting non-main branches do not receive pull-request-triggered validation. Run 43175060644 was a push run, not a PR event.
- No local Godot executable/editor was available to this audit. No local import, parser, scene-load, physics, desktop display, export or performance test was run. Runtime evidence above is from GitHub Actions only.

### Documentation and task coordination

- PR #9's task board records the stale PR #1 base, the missing movement-regression parent, the CI trigger gap, PR #8's branch-only audio result and the blocked product-owner decision.
- The research comparison is decision support only. No game direction, mechanic, design pillars or first-playable scope was selected.
- No real bot assignment or other agent activity was confirmed. Suggested specialist roles remain suggestions.
- This audit branch updates only `DAILY_QA_LOG.md` and `ISSUE_REGISTER.md`. No game code, scenes, assets, UIDs, import sidecars, project settings or workflows were changed. No files were moved or deleted. Main and all existing contributor branches were left untouched.

### Next highest-priority objective

**Reconcile PR #1 with current main without rewriting shared history.** Inspect the five main-only commits against the 40-file foundation diff, integrate or resolve them through an ordinary reviewed branch update, then confirm PR #1 becomes mergeable and rerun Godot 4.7.2 validation on the resulting head. Keep downstream PRs in dependency order and recover the unrepresented movement-regression parent before PR #6 integration. Do not merge without review and explicit project-owner approval.

## 2026-11-09 — Repository structure, integration and CI audit

**Role:** Project quality manager / repository steward  
**Repository:** [Legioniz/LatchPoint](https://github.com/Legioniz/LatchPoint)  
**Engine target:** Godot 4.7.x  
**Audit scope:** main tree, active branch tree, branches, open PRs, issue #3, recent workflow runs and selected CI job logs.

### Repository and branch state

- The repository metadata reports default branch `main`.
- Inspected main HEAD: `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`.
- Inspected foundation branch: `feature/gameplay-foundation` at `58310c34342eed3bbe7b80cf3e2c9fd253acb566`.
- Inspected fullscreen branch: `fix/windowed-borderless-toggle` at `ae7c8de03b6502d3b38fa1c481fb6fdf89df6f62`.
- Inspected audio-investigation branch: `fix/audio-server-shutdown-grace` at the same SHA as the fullscreen branch.
- Inspected documentation branch: `docs/audio-shutdown-leak-investigation` at `5fb8316add5713907c491aa3b5b8c150436aee43`.
- Two fix branch names currently point to the same commit. This may be an alias or leftover branch; do not delete it until PR, issue and contributor references are checked.
- The complete repository tree at main was inspected; it was not truncated. The foundation branch tree was also inspected.

### Pull request dependency order

The three code/foundation PRs and this documentation PR are open and draft:

1. [PR #1 — Improve LatchPoint gameplay foundation](https://github.com/Legioniz/LatchPoint/pull/1), base `main`, head `feature/gameplay-foundation`.
2. [PR #2 — Fix fullscreen toggle window decorations](https://github.com/Legioniz/LatchPoint/pull/2), base `feature/gameplay-foundation`, head `fix/windowed-borderless-toggle`.
3. [PR #4 — Document audio playback shutdown warning investigation](https://github.com/Legioniz/LatchPoint/pull/4), base `fix/windowed-borderless-toggle`, head `docs/audio-shutdown-leak-investigation`.
4. [PR #5 — Add daily repository quality and multi-bot guidance](https://github.com/Legioniz/LatchPoint/pull/5), base `feature/gameplay-foundation`, head `docs/daily-quality-management`.

PR #5 is a documentation-only sibling PR based on the foundation branch. It does not modify the game code or the existing active branches. Review its documentation and links before merging it into `feature/gameplay-foundation`. Keep PR #1 → PR #2 → PR #4 dependency order intact. Re-check live SHAs and statuses before any merge.

### Project tree and dependency findings

- Main's older `Scene/main.tscn` references `res://bg/game_background_4/game_background_4.png`, which is not present in the inspected main tree. The foundation branch replaces it with a temporary ColorRect background.
- Main's older `AUDIO.gd` points to `res://MUSIC/Project_bullshit.mp3`, but the audio file exists at the project root. The foundation branch corrects the path and import sidecar.
- Main's old pause scene references an unavailable exit script and has callback integration issues. The foundation branch consolidates the pause actions into the pause controller.
- Main contains files named `COMMIT_EDITMSG`, `FETCH_HEAD`, `HEAD`, `config`, `description` and `index` at the repository root. These are copied Git metadata, not game assets. PR #1 removes them. Do not recreate them.
- The foundation branch removes confirmed empty prototype scenes/scripts and redundant button scripts only after inspecting their scene references.
- The foundation branch keeps the existing `Asset/`, `Scene/` and root-level script paths; no high-risk mass file move is warranted in this audit.
- Additional MP3 assets are present and require purpose/license confirmation before removal.

### CI and log inspection

- Workflow: `.github/workflows/godot-validation.yml`, installs Godot 4.7.2, imports resources, parses tracked GDScript, runs physics/scene smoke tests and boots the main menu.
- Latest inspected successful run: [42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526), job “Import, parse, smoke test and boot”. All listed workflow steps completed successfully.
- The physics smoke-test output reports that scenes loaded, the player landed, and floor, wall and ceiling collision checks held.
- **Important warning despite success:** after the physics test's pass message, Godot reports two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 and AudioStreamMP3 references, and `res://Project_bullshit.mp3`. The next boot-test process in that same run completes without the same warning in the inspected log.
- Open [issue #3](https://github.com/Legioniz/LatchPoint/issues/3) tracks this. The cause is not proven; do not silence or dismiss it because the process exit code is zero.
- Inspected an earlier failed workflow run [42571662445](https://github.com/Legioniz/LatchPoint/actions/runs/42571662445). Import, script parsing and physics smoke tests passed, but the boot display regression test failed while checking decorated windowed mode under the headless DisplayServer (`mode=1`, `borderless=false`). The later PR #2 update documents changing the headless assertion to check the borderless flag only; real desktop mode behavior remains a manual verification requirement.
- PR #2 reports a later successful Godot 4.7.2 run [42571742673](https://github.com/Legioniz/LatchPoint/actions/runs/42571742673). The latest successful run's detailed log was inspected directly for warnings.

### What the tests currently prove

- Main and supporting scenes are loaded/instantiated by the smoke test.
- Player floor contact is exercised in the gameplay scene.
- Generic deterministic CharacterBody2D probes test floor, wall and ceiling collision.
- The boot test loads the menu, checks the expected menu controls, and checks the fullscreen/windowed borderless flag.
- GDScript parse and project resource import are run in CI.

### What remains unverified

- Actual desktop fullscreen/window transitions and native title-bar decorations.
- Slopes, corners, one-way and moving platforms, tunneling at high gameplay speed, spawn overlap and multi-frame-rate behavior.
- Item, pickup, hazard, projectile and power-up collisions because those gameplay systems are not yet present.
- Save/load, local settings persistence, platform exports and performance baselines.
- ML playtesting; no agent/model training or execution was performed.
- Local Godot editor/runtime execution in this audit; the observed runtime validation came from GitHub Actions logs.

### Changes in this documentation-only task branch

- Added shared bot instructions, current project charter, architecture map, file structure guide, task board, issue register and this daily QA record.
- Updated the README to make the contributor and project-management documents discoverable.
- Did not move or delete game assets or code.
- Did not modify main or any active gameplay/fix branch.
- Did not run Godot locally. Documentation-only changes do not require a gameplay test; review links and consistency before merge.
- Opened [draft PR #5](https://github.com/Legioniz/LatchPoint/pull/5) targeting `feature/gameplay-foundation`. Its CI status should not be inferred from this docs-only change.

### Next recommended actions

1. Keep issue #3 open and investigate the audio playback resource retention without suppressing warnings.
2. Review PR #5 and merge it into the foundation branch only after documentation review.
3. Review the PR #1 → PR #2 → PR #4 dependency chain and retain draft status until all evidence and manual requirements are satisfied.
4. Obtain the product owner's decision on the core gameplay loop.
5. Add broader, deterministic physics coverage.
6. Verify remaining MP3 asset ownership and licenses before removing or reclassifying them.
