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


## 2026-11-14 — GitHub Actions trigger coverage and Node 24 compatibility

### Official GitHub Actions references
- Workflow trigger and branch-filter semantics: https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow
  - `push.branches` filters apply to pushed branch refs; `pull_request.branches` filters apply to the PR's target/base branch.
  - GitHub's glob syntax supports `**` for matching nested branch names. A catch-all avoids silently excluding new prefixes and stacked PR targets.
- Secure action usage: https://docs.github.com/en/actions/reference/security/secure-use
  - GitHub recommends full-length commit-SHA pins for third-party actions when a workflow dependency lockfile is not used.
- Node.js 20 deprecation/removal notice: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
  - GitHub's changelog records the Node 20 removal date as 2026-09-23. The inspected 2026-11-12 project run still warned that `actions/checkout@v4` was being forced to Node 24.

### Action release verification and licenses
- `actions/checkout` v7.0.1: https://github.com/actions/checkout/releases/tag/v7.0.1
  - Release tag resolves to commit `3d3c42e5aac5ba805825da76410c181273ba90b1`; its `action.yml` declares `node24`.
  - License: MIT (upstream LICENSE at https://github.com/actions/checkout/blob/v7.0.1/LICENSE).
- `chickensoft-games/setup-godot` v2.4.3: https://github.com/chickensoft-games/setup-godot/releases/tag/v2.4.3
  - Release tag resolves to commit `ac93246ea68518a384c1c280a496e5989341f2f6`; its `action.yml` declares `node24`.
  - License: MIT (upstream LICENSE at https://github.com/chickensoft-games/setup-godot/blob/v2.4.3/LICENSE).
- The two action manifests and license files were inspected directly at the referenced upstream tags. The repository pins the verified full commit SHAs and retains release labels as comments for maintainability.

### Design decision
- Run the existing Godot validation workflow for all branch pushes and all pull-request target branches using `**` filters.
- Pin the two external actions to immutable full commit SHAs. This avoids Node 20 compatibility warnings and reduces tag-movement risk.
- Keep the Godot version and all existing import/parse/physics/boot validation commands unchanged.
- Do not add dependencies, change gameplay code, or create a second overlapping test workflow.
- This change updates the root foundation workflow only. Existing downstream branch copies and default-branch integration remain explicit follow-up work.
