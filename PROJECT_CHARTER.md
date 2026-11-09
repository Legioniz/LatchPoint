# LatchPoint — Project Charter

**Status:** Early prototype; product/gameplay direction still requires confirmation.  
**Engine:** Godot 4.7.x  
**Primary implementation:** GDScript  
**Repository:** https://github.com/Legioniz/LatchPoint

## Current confirmed state

The reviewed foundation branch contains a 2D Godot project with:

- A player represented by CharacterBody2D, a capsule collision shape and an AnimatedSprite2D.
- Static platform collision geometry and a Camera2D.
- A main menu and a New Game / Load Game screen.
- An options screen with music-volume and fullscreen controls.
- An integrated pause menu.
- An Audio autoload and a default audio-bus layout.
- Headless scene, boot and basic physics smoke tests.

The repository has evidence of platforming controls, but the core gameplay loop and product promise are not yet fully specified.

## Product decision still required

The title LatchPoint is not sufficient evidence to define a grappling, tethering, latching, precision-platforming or other central mechanic. Do not silently commit to one.

Before a major gameplay expansion, agree on:

1. **Player promise:** what the player repeatedly does and what makes it satisfying.
2. **Core loop:** input, response, feedback, reward/progression and next decision.
3. **Win/fail states:** how a play session succeeds, fails or ends.
4. **Progression:** what changes between attempts, levels or sessions.
5. **Design pillars:** three to five principles that guide mechanics, presentation, difficulty and UX.
6. **First playable milestone:** the smallest coherent experience that proves the core loop.

Record the approved decision here and update the architecture, backlog and task board accordingly.

## Working principles

- Build a complete, understandable game loop rather than disconnected features.
- Prefer readable controls, clear feedback, responsive movement and fair collision behavior.
- Every mechanic must create a meaningful player decision or solve a technical problem.
- Research comparable large and small games, then adapt principles to LatchPoint instead of cloning them.
- Preserve Godot compatibility and favor the simplest maintainable implementation.
- Test changes in actual scenes and repeatable automated scenarios.
- Balance performance against player-facing quality using measurements.
- Keep save data safe, versioned and recoverable when persistence is introduced.
- Keep all assets original or appropriately licensed and attributed.

## Non-goals until approved

The following are not automatically authorized by the current prototype:

- A specific grappling or tethering system based on the title.
- A combat, RPG, roguelike, puzzle or metroidvania direction.
- Online multiplayer, servers, accounts or telemetry.
- A shipped machine-learning model.
- A complex upgrade economy or large content pipeline.
- Copying another game's protected code, assets, levels, characters or story.

## Definition of a first playable milestone

The first milestone should include a confirmed core loop, a start-to-finish playable segment, understandable controls, responsive feedback, consistent collision behavior, clear success/failure handling, restart/retry behavior, and automated regression coverage for critical paths.

Do not mark the project as production-ready until the target platform, performance budget, save requirements and release/export process are established.
