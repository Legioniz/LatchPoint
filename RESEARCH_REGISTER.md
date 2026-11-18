# Research Register

Initial baseline checked 2026-11-09; subsequent entries include their own check dates. Re-check sources when a design decision depends on an API or current implementation detail.

## Game-feel and player-control references

### Celeste — Maddy Thorson, developer-authored notes
- Source: https://www.maddymakesgames.com/articles/celeste_and_forgiveness/
- Scale: commercially released indie precision platformer.
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

## 2026-11-13 — Core-loop reference comparison (decision support only)

**Scope:** LP-DES-001 asks for a comparison of larger/commercial and smaller/independent games before the product owner chooses LatchPoint's player promise. This entry compares three distinct 2D/traversal design patterns. It does not select a genre or authorize a mechanic.

### Super Mario Bros. Wonder — Nintendo, large commercial 2D platformer
- Sources: Nintendo's official developer interview (Japanese, published 2023-10-18): https://www.nintendo.com/jp/interview/aqmxa/index.html
- Scale/context: a major, long-running commercial side-scrolling platform series. The official interview is in Japanese; the findings below are an English paraphrase. It identifies Wonder Flower as a trigger for substantial changes to the play of an individual course.
- Observed design principle: the developers describe wanting each course to contain at least one moment that surprises or delights players, and describe cross-discipline ideation followed by prototyping. They also discuss keeping familiar world rules trustworthy while presenting unusual changes as a distinct "Wonder" event.
- Potential LatchPoint application: if the owner chooses authored course-based play, a small first slice could center on one readable course-specific twist while keeping basic movement and collision rules consistent.
- Trade-offs: course-by-course novelty requires a steady supply of original ideas and authored content; Nintendo's team size and production budget are not a realistic scope template for this prototype.
- License/IP note: the game, interview text, characters, visuals, audio and level designs are proprietary. The interview was used as design research only. No text, code, characters, assets or level layouts were copied.

### Celeste — Maddy Thorson / Extremely OK Games, commercial precision platformer
- Source: developer-authored technical/design notes: https://www.maddymakesgames.com/articles/celeste_and_forgiveness/
- Scale/context: commercially released precision platformer; the source is written by a developer and documents moment-to-moment movement affordances.
- Observed design principle: coyote time, jump buffering, jump-apex gravity adjustment, corner correction and other small timing/position allowances widen the window for successful player input. The author summarizes these as small favors that make a demanding game feel more forgiving.
- Potential LatchPoint application: if the owner chooses precision traversal, assess input forgiveness as a control-quality tool after a baseline challenge exists; do not add every technique automatically.
- Trade-offs: these techniques tune an already-defined jump/dash loop; they do not themselves define a game's player promise, progression or level structure.
- License/IP note: the article and game are copyrighted. The notes are descriptive research only; no proprietary implementation or assets are reused.

### A Short Hike — Adam Robinson-Yu, small independent exploration game
- Sources: official game site https://ashorthike.com/ ; Steam feature description https://store.steampowered.com/app/1055540/A_Short_Hike/ ; GDC 2020 postmortem https://www.gdcvault.com/play/1028679/Independent-Games-Summit-Crafting-A
- Scale/context: independent game by Adam Robinson-Yu; the GDC session describes a deliberately small project and an initial release developed within a four-month deadline.
- Observed design principle: the public game description frames a summit as the broad goal while allowing players to choose paths, explore at their own pace, discover hidden treasures, meet other hikers and take optional activities. Collectibles can support reaching new heights, so exploration rewards also extend traversal.
- Potential LatchPoint application: if the owner chooses exploration, a compact connected space with a visible destination, optional detours and a small number of traversal rewards can create meaningful route choice without requiring a large world.
- Trade-offs: the game is a 3D/isometric exploration experience, not a direct 2D platformer template. Its appeal depends on landmark placement, world readability and optional content; those costs should be considered before choosing an exploration loop.
- License/IP note: the game, art, writing, characters, soundtrack and world are proprietary. The official site, store description and GDC session were used as research only; no assets, code, text or map layouts are reused.

### Godot Engine demo projects — open-source technical comparison
- Sources: repository https://github.com/godotengine/godot-demo-projects ; 2D platformer player script https://github.com/godotengine/godot-demo-projects/blob/master/2d/platformer/player/player.gd
- Scale/context: official Godot demonstration/template projects; the repository states that its demos are distributed under the MIT license.
- Observed technical pattern: the 2D platformer example uses `CharacterBody2D` and separates player, level and collectible responsibilities into distinct scripts/scenes. It is a more complete technical sample than LatchPoint's current single test environment.
- Potential LatchPoint application: use it as a reference when a concrete scene or interaction needs comparison; prefer the smallest subset that solves an identified project need.
- License note: MIT applies to the demo repository as stated in its LICENSE.md. No code, art, music or scenes are copied or imported.

### Godot 4.7 — CharacterBody2D official guide
- Source: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
- Relevant behavior: CharacterBody2D is controlled by project code, movement should run in `_physics_process()`, and `move_and_slide()` supplies a common slide response suitable for many platformers.
- Project application: the current player controller can support a small movement prototype, but the API choice does not decide the intended game loop.

### Comparison and design implications

| Pattern | Repeated player activity | Main reward/feedback | Content/engineering pressure |
|---|---|---|---|
| Course-based surprise (Super Mario Bros. Wonder) | Traverse a designed course and encounter a focused course-specific change | Immediate novelty and course completion | Many authored courses or reusable variations; strong need for predictable baseline rules |
| Precision challenge (Celeste) | Execute demanding movement sequences and refine timing/position | Responsive movement and mastery of difficult traversal | High control/collision polish; careful difficulty and retry tuning |
| Open exploration (A Short Hike) | Choose routes, explore landmarks and work toward a broad destination | Discovery, optional activities and traversal expansion | World readability, route design and optional content; more navigation/landmark work |

These are alternative patterns, not a feature checklist. The current LatchPoint repository confirms a 2D CharacterBody2D prototype with static platform geometry and basic left/right/jump controls; it does not yet contain a defined goal, fail state, reward loop, collectible system, level progression or approved signature mechanic. Therefore the current evidence is insufficient to select one of these patterns on the owner's behalf.

### Recommendation and next decision

- Keep LP-DES-001 blocked on the product-owner decision; do not infer a tether/grapple/latch mechanic from the title.
- Present the three patterns as neutral choices: authored course challenge, precision movement challenge, or compact exploration. The owner may also specify a different direction.
- After a direction is chosen, build one short greybox slice around a single repeated player action, immediate feedback, a clear goal/reward and the next decision. Include a fail/retry loop only if the chosen concept needs one.
- Compare prototypes with a small, consistent playtest: can a new player explain the goal and primary action; do intended inputs produce predictable results; are there meaningful decisions; can the player identify success/failure; and do players understand why they would continue or retry? These are proposed questions, not measured results.
- Do not implement collectibles, dash/corner correction, Wonder-style transformations, open-world systems or other reference mechanics until the owner approves a direction and the prototype demonstrates their value.

**Decision status:** research comparison prepared on 2026-11-13; no game direction, mechanic, design pillar or first-playable scope has been approved. No gameplay code or assets changed.


## 2026-11-16 — Classifying copied Git metadata on a historical branch

### Official Git references
- Repository layout: https://git-scm.com/docs/gitrepository-layout
  - Git documents `HEAD`, `config` and `index` as repository metadata under `$GIT_DIR`; in a standard working tree this is the `.git/` directory.
- Fetch behavior: https://git-scm.com/docs/git-fetch
  - Git writes fetched ref/object information to `.git/FETCH_HEAD`.
- Commit behavior: https://git-scm.com/docs/git-commit
  - Git documents `$GIT_DIR/COMMIT_EDITMSG` as the message file for a commit in progress.
- General repository model: https://git-scm.com/docs/git
  - A normal working tree's `.git` directory contains the object database, index and refs; root-level files with similar names are not automatically the active metadata directory.

### Repository observations
- `automation/playability-baseline` is at `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`; comparison with `main` reports zero commits ahead and nine behind. It is the merge base of PR #1 and has no unique commits relative to main.
- No current PR uses the automation branch as its base or head.
- Six similarly named files are tracked at the project root on that branch. Text inspection found an old commit message, a former remote URL, a local branch pointer and a generic description. The root `config` contains no credential in the inspected text. The binary `index` was not decoded.
- Main's previous cleanup commit [9ce61c5](https://github.com/Legioniz/LatchPoint/commit/9ce61c5e014927aa3c90a14a0ea941e98823d42b) removed three of these files from main; PR #1 already proposes removal of the remaining root-level `config`, `description` and `index` copies.

### Design decision and safety
- Treat the root-level copies as ordinary tracked project files, not active GitHub-hosted repository configuration. Do not execute or use them as a local Git repository.
- Retain `automation/playability-baseline` unchanged as a historical baseline and PR #1 comparison point. Do not delete the branch, rewrite history, or duplicate the cleanup already proposed in PR #1 without explicit owner direction.
- No Git commands, code, assets or dependencies were copied into the project. The official documentation was referenced for classification only; no source text or implementation was reused.
- The binary index remains uninspected beyond confirming its presence and encoded size; no statement is made about its internal paths or entries.


## 2026-11-17 — Audio asset provenance audit (research-lite)

**Objective:** establish what can be verified about the four retained MP3 files without deleting, relabeling or redistributing material whose rights are unknown.

### Technical reference
- Godot 4.7 Import Process: https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html
- Godot documents that each imported source asset has a companion `.import` file containing important import configuration and that these sidecars should be committed. The generated `.godot/imported/` cache is separate and should not be committed. This supports preserving the source files and sidecars while correcting their paths; it does not establish copyright or permission.

### Repository evidence (checked 2026-11-17)
- The default-branch tree contains `Project_bullshit.mp3`, `Tung.mp3`, `maj.mp3` and `yi.mp3` at the repository root, each with a companion `.import` file.
- Default-branch GitHub code search found `Project_bullshit.mp3` in `AUDIO.gd`. Searches for the other three names returned only their own `.import` sidecars. This search covers the default branch only and is not a complete audit of every branch, dynamic path construction or runtime-generated resource path.
- All four MP3s were introduced together in commit https://github.com/Legioniz/LatchPoint/commit/8e586c1eb3c52f11b5c5167355e663587363d245 (2026-08-23, author account `Codfyyy`, message “Add files via upload”). The commit metadata contains no source URL, license, attribution or intended-use statement.
- The current root `LICENSE` and `COPYRIGHT.md` distinguish owner-controlled materials from third-party audio and state that third-party materials retain their own terms. Repository presence and commit authorship do not prove the project owner owns or may redistribute these MP3s.
- On `main`, all four sidecars use `res://MUSIC/<filename>.mp3` even though the source files are at the project root. PR #1 corrects the Project track sidecar; PR #12 corrects the other three. Those path changes are technical import repairs only and do not settle provenance.

### Decision and limits
- Keep all four binaries and their UIDs/import metadata unchanged. Do not delete the three currently unreferenced-by-default-code-search tracks, because the search is not exhaustive and ownership is unknown.
- Do not treat the current proprietary notice as a license for third-party audio. Obtain source, rights-holder, permission/license and intended-use confirmation from the asset owner before release or redistribution.
- This is research-lite: the task is repository provenance, not a gameplay feature. No commercial/indie game mechanic comparison was relevant; no external audio, code or assets were copied or reused. The binary audio contents were not downloaded, played or identified.


## 2026-11-18 — High-speed CharacterBody2D regression review (research-lite)

### Technical references
- Godot 4.7 CharacterBody2D movement and collision: https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html
  - The official guide describes code-driven CharacterBody2D movement in the physics callback and collision resolution through move_and_slide().
- Godot Demo Projects — Kinematic Character 2D: https://github.com/godotengine/godot-demo-projects/tree/master/2d/kinematic_character
  - The official demo-project repository declares the MIT license. It was reviewed as a technical implementation comparison only; no code, scenes or assets were copied.

### Test interpretation and decision
- PR #13 adds test-only floor, wall and ceiling probes with a 20×20 CharacterBody2D shape and 20-pixel-thick fixtures. The commanded speed is derived from the configured physics tick rate to produce 100 pixels of requested displacement per tick (6,000 pixels/second at the 60 Hz default).
- The test asserts the expected floor/wall/ceiling classification and that the body did not pass through the fixture. The passing Godot 4.7.2 run [44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467) verifies this specific headless fixture/configuration; it does not establish a universal collision guarantee or test high-speed movement of the shipping player.
- This is an engine-level regression test, not a gameplay mechanic. A commercial/indie game comparison is not relevant to this narrow objective; the existing 2026-11-13 game-design comparison remains the decision-support reference for LP-DES-001.
- No third-party code, art, audio, levels or other assets were reused. No new dependency or license obligation was introduced by this review.
