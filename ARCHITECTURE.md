# LatchPoint — Architecture

**Reviewed against:** `feature/gameplay-foundation` and its descendants on 2026-11-09.  
**Important:** these changes are in an open draft PR stack and are not yet the default-branch state. Re-inspect the active tree before using this document as a migration source.

## Runtime overview

### Project entry

- `project.godot` names the application LATCHPOINT.
- Main scene is configured by UID `uid://c8l60tak5vrn8`, currently `menu.tscn`.
- Autoload `Audio` points to `AUDIO.gd`.
- Target engine features identify Godot 4.7 and Forward Plus.
- The project currently uses GDScript.

### Scene flow

```text
project.godot
└── menu.tscn
    ├── Play -> new_load.tscn
    │   ├── New Game -> Scene/main.tscn
    │   └── Load Game -> disabled until saving exists
    ├── Settings -> options_menu.tscn
    └── Quit -> application exit

Scene/main.tscn
├── Player (Scene/player.tscn)
│   ├── CharacterBody2D + Scene/player.gd
│   ├── CollisionShape2D
│   ├── AnimatedSprite2D
│   └── Camera2D
├── StaticBody2D platform fixtures
├── Background ColorRect
└── PauseMenu (pause_menu.tscn)
```

## System responsibilities

| Component | Responsibility | Integration points |
|---|---|---|
| `menu.tscn` | Main navigation and entry | Embedded GDScript; menu scene transitions |
| `new_load.gd/.tscn` | Start new game; explicitly disable unsupported load | Loads `Scene/main.tscn` |
| `Scene/main.tscn` | Gameplay composition, world geometry and camera | Player scene, platform bodies, background, pause menu |
| `Scene/player.tscn` | Player node, collision capsule and sprite frames | `Scene/player.gd`, player art |
| `Scene/player.gd` | Horizontal movement, gravity and jump input | Godot input actions and CharacterBody2D physics |
| `pause.gd` / `pause_menu.tscn` | Pause state, resume, return and quit actions | SceneTree pause state, main menu scene |
| `options_menu.gd/.tscn` | Return navigation and options UI | Music slider and fullscreen toggle |
| `Music-Control.gd` | Reads/writes the Music bus level | Audio autoload when available; AudioServer fallback |
| `resolution.gd` | Synchronizes Fullscreen checkbox, Window.mode and borderless flag | Current Window |
| `AUDIO.gd` | Owns background music player and in-memory bus volumes | AudioServer buses and root autoload lifecycle |
| `default_bus_layout.tres` | Defines Master, Music and SFX routing | AudioServer |
| `tests/*` | Headless boot, scene, physics and collision probes | Godot SceneTree and project scenes |

## Current data and state boundaries

- There is no implemented save/load layer yet. Load Game is intentionally disabled.
- Audio volume values are currently kept in the Audio autoload's in-memory dictionary. Persistence across application restarts is a backlog item.
- Display mode is set through the current Window and is not documented as persisted.
- No network backend, player account system or external telemetry is established.
- No ML agent/model is part of the shipped project. ML-assisted playtesting is a future test-only option once an objective and state/action interface exist.

## Key path and identity rules

- Preserve scene and script UIDs in `.uid` sidecars.
- Preserve resource import metadata in `.import` sidecars.
- Update all resource paths when moving files, including in scenes, scripts, import metadata, CI and docs.
- Exact case matters: current source directories are `Asset` and `Scene`, while the test directory is `tests`.
- Current root-level scripts are intentional existing paths until a safe, complete relocation is designed. Do not relocate them piecemeal.

## Known integration gates

1. PR #1 is the foundation PR against main. Review its complete diff and CI evidence before merging.
2. PR #2 is a fullscreen/window-decoration follow-up based on the foundation branch.
3. PR #4 documents the MP3 playback shutdown investigation and is based on the fullscreen branch.
4. PR #1 -> PR #2 -> PR #4 is a dependent review chain. Confirm current base/head SHAs and merge state before changing it.
5. Issue #3 tracks MP3 playback references retained after the physics smoke test. The root cause is not confirmed.
6. The core game design remains unconfirmed. Large gameplay architecture should wait for that decision.

## Design boundaries

- Gameplay rules belong in gameplay scripts/resources, not embedded menu code.
- UI controls should have a real action or an honest disabled state.
- Physics behavior must use physics processing and be covered by repeatable tests.
- Audio and display settings should have a single clear owner; avoid parallel scripts directly fighting over the same setting.
- Introduce managers, state machines, event buses or resource abstractions only when they simplify an actual dependency.
