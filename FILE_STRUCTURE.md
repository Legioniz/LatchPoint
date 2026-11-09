# LatchPoint — File Structure and Placement Rules

**Baseline inspected:** foundation branch and dependent PR branches on 2026-11-09.  
**Do not assume this proposal is already merged into main.**

## Current reviewed structure

```text
LatchPoint/
├── .github/
│   └── workflows/
│       └── godot-validation.yml
├── Asset/
│   └── images/
│       └── Player/
│           ├── cali_character_Sprite*.png
│           └── matching .import files
├── Scene/
│   ├── main.tscn
│   ├── player.tscn
│   ├── player.gd
│   └── player.gd.uid
├── tests/
│   ├── boot_smoke_test.gd
│   ├── physics_probe.gd
│   └── physics_smoke_test.gd
├── AUDIO.gd (+ .uid)
├── Music-Control.gd (+ .uid)
├── resolution.gd (+ .uid)
├── menu.tscn
├── new_load.gd (+ .uid)
├── new_load.tscn
├── options_menu.gd (+ .uid)
├── options_menu.tscn
├── pause.gd (+ .uid)
├── pause_menu.tscn
├── Project_bullshit.mp3 (+ .import)
├── other MP3 assets (+ .import sidecars)
├── default_bus_layout.tres
├── project.godot
├── icon.svg (+ .import)
├── README.md
├── DEVELOPMENT_PLAYBOOK.md
├── IMPROVEMENT_BACKLOG.md
├── IMPROVEMENT_LOG.md
├── RESEARCH_REGISTER.md
└── AGENTS.md / project guidance documents
```

The exact current tree must always be checked on the branch being edited. This diagram is a map, not permission to move files.

## Existing placement conventions

- `Scene/` contains the active gameplay scenes and player controller.
- `Asset/images/Player/` contains player sprite source images and Godot import sidecars.
- Root-level scripts are referenced by scenes and/or the Audio autoload. Their root placement is existing convention, even if a future structure could be more organized.
- `tests/` contains headless test scripts and test-only physics fixtures.
- `.github/workflows/` contains GitHub Actions automation.
- Project planning and research files are currently kept at the root for easy access.
- `.uid` and `.import` files are Godot metadata and must be considered alongside the source file they identify.

## Placement rules

1. Preserve the existing directory case unless a documented migration is approved.
2. A source file and its required UID/import sidecars move as one logical unit.
3. Keep tests isolated from shipping scenes and runtime code.
4. Store documentation at the root when it is a repository-wide contributor guide; use a Docs folder only if the volume justifies it.
5. Keep scene assets near the existing asset taxonomy and avoid duplicate copies.
6. Never commit Godot-generated cache folders, local editor state, temporary exports or machine-specific files.
7. Every folder must contain a meaningful project asset, test, source file or document. Git does not preserve empty directories.
8. Do not keep duplicate copies of the same script or resource under slightly different names.

## Future relocation proposal (not yet approved)

A later cleanup may consider consolidating the mixed-case structure into a consistent convention such as:

- `Scenes/`
- `Scripts/`
- `Assets/`
- `Resources/`
- `Tests/`
- `Docs/`

This is only a proposal. Do not start a mass move until:

- the current foundation PR chain is settled;
- all existing paths, UIDs and import dependencies are inventoried;
- a complete path migration can be made in one focused PR;
- Godot import, script parsing, scene loading and CI all pass after the move;
- rollback and reviewer approval are provided.

## File purpose audit

The following MP3 files exist in the reviewed branch: `Project_bullshit.mp3`, `Tung.mp3`, `maj.mp3`, and `yi.mp3`. The currently inspected Audio autoload references only `Project_bullshit.mp3`. The purpose, intended use and license status of the other tracks need confirmation before any deletion or relocation. Do not remove them based only on a failed text search.

The current root-level script and scene paths are not automatically clutter. Verify their references before classifying anything as unused.
