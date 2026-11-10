# LatchPoint Development Playbook

## 1. Product objective

Build LatchPoint into a coherent, responsive, enjoyable and technically reliable game. Every new mechanic must reinforce a recognizable player experience. The current repository proves that LatchPoint is a Godot 4.7 2D prototype, but it does not yet document the definitive core loop or the meaning of its title. Do not assume the game must use grappling, latching or any other mechanic based on its name alone.

Before committing to a major mechanic, establish:
- **Player promise:** what the player repeatedly does and why it is satisfying.
- **Core loop:** input → game response → feedback → reward/progression → next decision.
- **Design pillars:** three to five principles that guide mechanics, art, UX and difficulty.
- **Scope:** what belongs in the first playable milestone and what is deliberately excluded.

## 2. Evidence-led research

For every substantial feature, consult multiple sources:
1. At least one larger/commercial game with a comparable player experience.
2. At least one indie, small or open-source game with a comparable mechanic or production constraint.
3. Official Godot 4.7 documentation for the engine APIs involved.
4. Developer talks, postmortems, public source code or reputable testing references where available.

Compare the feel and purpose of the mechanic, control behavior, edge cases, level design implications, accessibility, performance costs and player feedback. Record findings and links in [RESEARCH_REGISTER.md](RESEARCH_REGISTER.md). Cite the specific principle that influenced the implementation. Do not copy another game's protected code, art, music, characters, text or level design. Verify the license and attribution requirements before reusing any source or asset.

Research should inform a decision, not force LatchPoint to imitate a reference game. A good pattern can be rejected when it does not fit the game's pillars.

## 3. The development cycle

Each cycle should complete one meaningful unit of work:

1. **Inspect:** review the current tree, project settings, active branch, open PRs, recent commits, issues, CI results and previous improvement records.
2. **Choose:** select one high-value backlog item with a clear purpose and dependencies.
3. **Research:** compare relevant large and small games, engine documentation and implementation references.
4. **Specify:** write acceptance criteria, failure cases, test plan, performance cost and rollback plan.
5. **Design:** map every impacted scene, script, signal, resource, input action, autoload, asset and save schema.
6. **Implement:** make the feature complete across its dependent systems. Avoid half-finished buttons, orphan callbacks, hard-coded paths and disconnected UI.
7. **Verify:** run focused tests, full import/parse checks, integration checks and relevant gameplay/physics scenarios.
8. **Review:** inspect the full diff for broken paths, missing UIDs/resources, duplicated logic, regressions, unused files, license problems and performance cost.
9. **Document:** update the research register, improvement log and backlog.
10. **Deliver:** push a focused branch and open/update a draft PR with test evidence. Keep `main` protected until the change is verified.

A cycle may end with a documented blocker when no safe implementation can be made. Do not add activity for its own sake.

## 4. Architecture and integration

- Godot 4.7 and GDScript are the default platform.
- Keep game rules separate from presentation where that improves testability.
- Use scenes as reusable composition units; use Resources for meaningful shared/configurable data.
- Use signals/events for decoupled communication when they reduce direct dependencies; avoid a global event bus without a real need.
- Introduce state machines when behavior has meaningful states and transitions, not for a two-branch function.
- Keep physics movement in `_physics_process`. Use `CharacterBody2D` methods deliberately and inspect collision results when gameplay needs them.
- Centralize settings, persistence and input ownership. Avoid multiple scripts controlling the same property.
- Add C# or native extensions only when a measured performance, ecosystem or integration need outweighs added complexity.
- Every button must have a working action or be visibly disabled with an honest explanation.

## 5. Physics and collision verification

Physics must be observed in repeatable scenarios, not approved from code inspection alone.

| Scenario | Required checks |
|---|---|
| Floor and platform | Stable landing, no sinking, no jitter, correct grounded state |
| Walls and corners | No penetration, predictable sliding/stopping, no corner snag unless intentional |
| Ceiling | Jump head contact resets or preserves velocity according to the intended rules |
| Slopes and one-way platforms | Correct floor classification and predictable pass-through behavior |
| Moving platforms | Player carries/retains motion only when intended |
| Fast movement | No tunneling through thin geometry; collision response remains stable |
| Spawn/respawn | No initial overlap with solid geometry; checkpoint placement is safe |
| Items and pickups | Trigger radius, entry/exit, duplicate overlap, pickup once, respawn/consumption |
| Hazards and projectiles | Hitbox alignment, damage timing, cooldowns, knockback and invulnerability |
| Power-ups | Duration, stacking rules, expiry, removal and collision effects |
| Frame rate | Movement is time-step aware; behavior is compared at supported physics/render rates |

For each physics change, retain a minimal regression test and a reproducible setup. Verify collision layers/masks, collision shape dimensions and sprite alignment. Enable Godot's visible collision shapes during manual testing.

## 6. Automated testing and ML-assisted playtesting

### Required baseline

- Import/parse the complete project headlessly.
- Load every important scene and resource.
- Run deterministic tests for affected scripts and gameplay systems.
- Exercise scene changes, input, pause/resume and failure/recovery paths.
- Run physics integration tests for the actual bodies and shapes.
- Inspect GitHub Actions output and failure logs. A workflow file existing is not evidence of a passing test.

GdUnit4 or a small in-project test harness can be used depending on dependency cost. Keep tests outside shipping scenes and document the purpose of each test file.

### Machine-learning-assisted tests

Once the core loop provides a reliable state/action interface and measurable objectives, evaluate a local playtesting agent. Suitable objectives may include completing a level, reaching a checkpoint, collecting an item, surviving hazards or discovering stuck/unreachable states. Save the seed, input trace and game state for each failure so it can be reproduced.

A trained model may help explore combinations humans do not test often, but it is not proof of correctness. Compare ML findings with deterministic test cases and human playtests. Do not call random fuzzing or a hand-written heuristic ML. Do not ship a model unless it improves the player's experience. Prefer offline test data and avoid unnecessary telemetry or external personal-data collection.

If training infrastructure is not available or would add more cost than value, report that clearly and use deterministic bots, seeded fuzzing and integration tests instead.

## 7. Save and progression standards

When the core loop is ready, implement persistence with:
- Local save storage and a documented schema version.
- Validation and safe defaults for absent or malformed fields.
- Atomic writes, a backup/recovery strategy and migration tests.
- Explicit ownership of unlocks, currencies, inventory, settings and checkpoint state.
- Export/import with format version, compatibility checks and integrity validation.
- Clear semantics for any locked/protected export. A local client-side lock is not tamper-proof against a determined user.

Never expose a Load button until a real save/load flow exists. Never silently discard an incompatible save.

## 8. Performance and quality

Profile before optimizing. When relevant, observe frame time/frame pacing, memory, loading time, physics body count, draw calls, overdraw and imported asset size. Set targets based on the actual target hardware and game experience. Prefer an understandable solution with stable performance over clever code that cannot be maintained.

## 9. File purpose and repository hygiene

Every committed file must have a purpose: runtime feature, required engine metadata, test, documentation, source asset or intentionally preserved prototype. Track dependencies through scene references, UID paths, autoloads, signals, groups, input maps and dynamically loaded resources. Remove files only after confirming they are unused. Never commit copied `.git` internals, editor caches, local logs, temporary builds or generated test output. Do not remove imported metadata that Godot requires unless its lifecycle is understood.

## 10. Git, PRs and collaboration

Use one isolated feature branch per coherent task. Inspect other open PRs before editing to avoid duplicated or conflicting work. Review outside contributions and bot-generated code like any other patch: read the complete diff, check licensing, run tests and inspect logs. Coordinate through issues, PRs and the backlog rather than simultaneous edits. No force-push or silent history rewrite. No merge to `main` until the required checks pass.

## 11. Cycle completion checklist

- [ ] Purpose and acceptance criteria are explicit.
- [ ] Research includes relevant larger and smaller references.
- [ ] All affected scenes, scripts, resources, signals and assets are integrated.
- [ ] Physics/collision cases relevant to the change are tested.
- [ ] Static, scene, unit and integration checks are run where available.
- [ ] ML/agent testing is used only when it adds real test coverage and is truthfully described.
- [ ] Performance and regression risks are reviewed.
- [ ] No confirmed orphan code, unused files or copied Git metadata remain.
- [ ] `RESEARCH_REGISTER.md`, `IMPROVEMENT_LOG.md` and `IMPROVEMENT_BACKLOG.md` are updated.
- [ ] CI logs, PR link, commit and unverified risks are reported accurately.
