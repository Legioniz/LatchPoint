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

## 2026-11-15 — Repair retained MP3 import sidecar paths

**Goal:** make the committed MP3 import metadata agree with the actual source-file locations, without deleting or altering audio assets whose provenance is not established.

### Evidence
- The inspected foundation tree contains `Tung.mp3`, `maj.mp3`, `yi.mp3` and `Project_bullshit.mp3` at the project root, and contains no `MUSIC/` directory.
- The `Tung`, `maj` and `yi` sidecars still named `res://MUSIC/<file>.mp3` as `deps/source_file`; the Project track sidecar was already corrected on the foundation branch.
- Default-branch code search returned only the three sidecars for those filenames. The foundation Audio autoload uses only `Project_bullshit.mp3`; this does not prove that no dynamic reference exists in every historical branch.
- The three files' shared upload history is dated 2026-08-23 and has the generic message “Add files via upload”. No source or license information was found in the inspected repository records.

### Changes
- Corrected only the `deps/source_file` entry in `Tung.mp3.import`, `maj.mp3.import` and `yi.mp3.import`.
- Added a deterministic check to `tests/physics_smoke_test.gd` that loads all four MP3 sidecars with `ConfigFile`, checks the exact expected source path, and verifies that the source file exists.
- Preserved all MP3 binaries, UIDs, imported destination names, import parameters and other project files.

### Research and licensing
- Godot 4.7 Import Process: https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html
- Godot documents that imported assets have a companion `.import` metadata file and that these files should be committed. See `RESEARCH_REGISTER.md` for the technical decision and licensing limitation.
- No audio was copied or modified. The provenance/license question remains open; the assets are retained pending owner confirmation.

### Verification
- Godot 4.7.2 GitHub Actions validation is required after pushing this branch. No local Godot executable was available in this execution environment.
- No physics/collision behavior, audio playback behavior, scene geometry or runtime architecture changed.
- Manual audio playback, desktop verification, performance profiling and ML testing were not performed.
