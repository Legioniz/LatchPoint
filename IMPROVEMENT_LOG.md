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


## 2026-11-14 — Normalize CI trigger coverage and action runtimes

**Objective:** close the branch-filter gap in the foundation validation workflow and remove its deprecated Node.js 20 checkout action.

### Repository evidence
- The foundation workflow previously ran pushes only on `main` and `feature/**`, and pull requests only when targeting `main`.
- The live branch set includes `automation/**`, `docs/**`, `feature/**`, `fix/**` and `quality/**`; stacked PRs also target non-main branches.
- Downstream workflow copies differ: some include `fix/**`, while docs/quality branches still lack push coverage and PR filters still target only `main`.
- Latest observed run [43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) passed its Godot import, parser, physics and boot checks, but emitted a Node.js 20 deprecation warning for `actions/checkout@v4`.

### Changes
- Changed push and pull-request branch filters to `**`, covering nested branch names and stacked PR base branches without maintaining a prefix allowlist.
- Pinned `actions/checkout` to verified commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1, Node 24).
- Pinned `chickensoft-games/setup-godot` to verified commit `ac93246ea68518a384c1c280a496e5989341f2f6` (v2.4.3, Node 24).
- Preserved the existing Godot 4.7.2 import, GDScript parse, physics smoke and boot smoke steps unchanged.

### Acceptance and verification plan
- A push to this `ci/**` branch must start the workflow.
- Godot 4.7.2 import, every tracked GDScript parse, physics smoke and boot smoke must pass.
- Inspect the final job log for the absence of the Node.js 20 deprecation warning.
- Confirm that the action SHAs resolve to the stated upstream release tags and that no gameplay/runtime files changed.

### Integration limitations
- This branch is stacked on PR #1's `feature/gameplay-foundation` branch. The default branch still has no validation workflow until the foundation PR is integrated.
- Existing downstream branches retain older workflow copies until they are synchronized or retired in the dependency chain.
- No gameplay, scene, asset, project-setting or runtime architecture files changed.
- Local Godot execution and manual desktop playtesting were not available for this cycle.
