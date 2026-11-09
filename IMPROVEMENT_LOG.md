# Improvement Log

Each completed cycle records its purpose, affected files, sources, verification evidence, remaining risks and PR/commit link. Unrun tests are explicitly marked as unverified.

## 2026-11-09 — Window decoration toggle regression

**Goal:** ensure the existing Fullscreen option reliably returns the game to a normal decorated window.

- Root cause: `project.godot` enabled `window/size/borderless`, while `resolution.gd` changed only `Window.mode`. Godot documents that entering fullscreen forces the borderless flag on; the flag must be reset when decorations are wanted.
- Set the default project window to decorated/windowed mode.
- Synchronize the fullscreen checkbox with both the window mode and borderless flag on initialization and toggle.
- Added a regression assertion to `tests/boot_smoke_test.gd` for the borderless flag during windowed initialization and when returning to windowed mode.
- The first headless regression attempt exposed a test-environment limitation: Godot's headless DisplayServer reported the root window mode as minimized (value 1), so asserting MODE_WINDOWED was invalid in that environment. The test now checks the borderless flag only; the actual mode transition remains a manual desktop verification requirement.
- Added `TESTING_GUIDE.md` and linked it from the README. Extended the CI push trigger to include `fix/**` branches.
- **CI verified:** Godot 4.7.2 import, all tracked GDScript parsing, physics smoke test, and boot/display-decoration regression test all passed on commit `8e408aa0a8c9cfa38e89743b23aa7071581eec9c`. Run: https://github.com/Legioniz/LatchPoint/actions/runs/42571742673
- CI logs still report existing AudioStreamMP3/ObjectDB resources in use at shutdown after both smoke tests, although the commands exit successfully. This is recorded as a separate cleanup issue; it was not changed in this display-settings fix.
- Local Godot runtime was not available. Actual fullscreen/windowed transitions and native title-bar behavior still require manual desktop verification.

**Research:** Godot DisplayServer documentation — https://docs.godotengine.org/en/latest/classes/class_displayserver.html

**Branch:** `fix/windowed-borderless-toggle` (PR #2 draft).

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
