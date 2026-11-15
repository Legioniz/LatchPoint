# Research Register

Checked 2026-11-09. These references establish the first research baseline. Re-check them when a design decision depends on an API or current implementation detail.

## Game-feel and player-control references

### Celeste — Maddy Thorson, developer-authored notes
- Source: https://www.maddymakesgames.com/articles/celeste_and_forgiveness/
- Scale: major commercial precision platformer.
- Observed design principles: coyote time, jump buffering, reduced gravity near the jump apex while jump is held, and corner correction are used to make platforming feel more forgiving and controllable.
- Potential LatchPoint application: evaluate input forgiveness only after the intended jump/interaction loop is defined. Measure whether it improves control without undermining challenge.
- Do not copy proprietary implementation or claim that every technique belongs in LatchPoint by default.

### Flick! — open-source Godot 4.x 2D platformer
- Source: https://github.com/codernunk/flick
- Scale: small independent/open-source game.
- Observed design principle: the game's identity is built around a distinct directional-launch ability. Its project also separates scenes and documents code/art licenses.
- Potential LatchPoint application: make one clear mechanic central to the player's decisions; keep reusable character/world elements modular.
- License note: the repository describes MIT-licensed source code and CC-BY-4.0 assets. Inspect the exact asset and attribution terms before reuse. No Flick code or assets are imported by this project.

### Joey's Slimeventure — open-source Godot 4.7 platformer
- Source: https://github.com/PondSec/JoeysSlimeventure
- Scale: actively developed independent game.
- Observed design principles: handcrafted pixel art is combined with procedural cave generation; public development separates stable `main` from an active development branch; the project emphasizes testable, documented PRs.
- Potential LatchPoint application: separate experimental development from stable releases and use procedural systems only when they improve replayability without making levels feel arbitrary.
- No code or assets are imported by this project.

### Out Of Reach — small game-jam puzzle platformer
- Source/devlog: https://bulldozerdev.itch.io/out-of-reach/devlog/1742901/out-of-reach-is-now-open-source
- Date noted by source: 2026-10-31.
- Scale: University of Waterloo Spring 2026 game-jam prototype.
- Observed design principle: a simple spatial rule (platforms moving away from the player) and gravity zones can carry a compact puzzle-platforming idea.
- Potential LatchPoint application: prototype one mechanic in a small playable level before expanding content. Verify license and project terms before reuse.
- This is a design reference only; no source or asset reuse is implied.

## Engine, physics and test references

### Godot 4.7 — CharacterBody2D movement and collision
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant points: `CharacterBody2D` is manually controlled; movement belongs in `_physics_process`; `move_and_slide()` is appropriate for many platformer situations; `move_and_collide()` returns collision information for custom responses; slide collisions can be inspected after movement.
- Project application: use physics APIs with a deliberate response model and test collision cases in the running project.

### Godot command-line validation
- Source: https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html
- Relevant points: headless import and command-line execution can be used in CI; `--import` performs project resource import; headless runs can execute scripts and projects without opening a game window.
- Project application: the initial GitHub Actions workflow imports the project and runs a deterministic smoke/physics test.

### GdUnit4
- Source: https://godot-gdunit-labs.github.io/gdUnit4/latest/
- Relevant points: supports Godot 4.x GDScript/C# unit and scene testing, test discovery, parameterized/fuzz testing, scene input simulation and CI reports.
- Project application: evaluate it when the test suite expands. A lightweight built-in harness is used first to avoid adding a framework before its value is proven.

### Godot setup action for CI
- Source: https://github.com/chickensoft-games/setup-godot
- Relevant points: installs Godot 4.x on GitHub Actions Linux/macOS/Windows runners and supports standard builds without .NET.
- Project application: install Godot 4.7.2 in the repository validation workflow.

## Decision rule

The references are inspiration and technical evidence, not a feature checklist. Each adopted pattern must be tied to the LatchPoint design pillars, implemented originally, tested and recorded in the improvement log. No external code, art, sound, level or character is copied by this register.

## 2026-11-15 — Godot imported-resource metadata and audio asset audit

### Godot 4.7 Import Process
- Source: https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html
- Checked: 2026-11-15.
- Findings: Godot places imported source assets in the project folder, generates a companion `.import` file containing import configuration, and stores generated imported resources under `res://.godot/imported/`. The documentation explicitly says to commit the companion import files because they contain important metadata.
- Applied decision: preserve the sidecars and their stable UIDs/import settings; correct only the stale `deps/source_file` paths so they point to the actual root-level MP3 source files. Add a test that checks the exact expected source path and source-file existence.
- No imported binary, audio data, UID, destination path or import parameter was changed.

### Audio provenance and licensing
- Repository history shows `Tung.mp3`, `maj.mp3` and `yi.mp3` were introduced together by an “Add files via upload” commit dated 2026-08-23. That commit message does not establish the original source, rights holder or license.
- The current `COPYRIGHT.md` distinguishes owner-controlled materials from third-party materials and says third-party assets remain subject to their respective terms. No per-file license/source attribution was found in the inspected records.
- Decision: do not delete, redistribute separately, modify or claim ownership of these audio files. Keep the asset-provenance task open until the owner supplies source and permission details. The current change is limited to technical import metadata and regression coverage.
- No commercial/indie game comparison was relevant to this asset-pipeline correctness task; no external code or assets were reused.
