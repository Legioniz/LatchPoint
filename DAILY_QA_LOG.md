# Daily QA Log

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
