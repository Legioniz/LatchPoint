# LatchPoint — Instructions for AI and Human Contributors

These instructions apply to every developer, AI coding agent, research agent, QA agent, and integration bot working in this repository.

## Read before acting

Start every task by checking the current branch, default branch, open pull requests, recent commits, CI status, and the task board. Then read the documents relevant to your assignment:

1. [PROJECT_CHARTER.md](PROJECT_CHARTER.md) — what the game is and what is not yet decided.
2. [BOT_TASK_BOARD.md](BOT_TASK_BOARD.md) — current priorities, owners/roles, dependencies and acceptance criteria.
3. [ARCHITECTURE.md](ARCHITECTURE.md) — how scenes and systems connect.
4. [FILE_STRUCTURE.md](FILE_STRUCTURE.md) — where files belong and what existing paths mean.
5. [ISSUE_REGISTER.md](ISSUE_REGISTER.md) — confirmed defects and investigations.
6. [IMPROVEMENT_BACKLOG.md](IMPROVEMENT_BACKLOG.md) — future work and its priority.
7. [DEVELOPMENT_PLAYBOOK.md](DEVELOPMENT_PLAYBOOK.md) — design, research, implementation and quality standards.
8. [TESTING_GUIDE.md](TESTING_GUIDE.md) — read it when present on your branch. If it is absent, inspect the newest test-bearing branch/PR before relying on test commands; do not assume an older guide matches your code.
9. [RESEARCH_REGISTER.md](RESEARCH_REGISTER.md) — previous references, findings and decisions.
10. [IMPROVEMENT_LOG.md](IMPROVEMENT_LOG.md) and [DAILY_QA_LOG.md](DAILY_QA_LOG.md) — recent changes and quality checks.

The current development PR stack may not yet be merged into main. Check the PR base and branch before assuming a document or fix is already present in the default branch.

## Project identity and decision discipline

- The confirmed technical baseline is Godot 4.7, GDScript and a 2D prototype with platform collision geometry.
- The final game identity, player promise and definitive core gameplay loop are not yet confirmed in the reviewed project material.
- Do not infer a grappling, latching, platforming, puzzle, combat or other defining mechanic from the name LatchPoint alone.
- Do not add major mechanics, progression systems, characters, enemies, or monetization without showing how they serve the approved game direction.
- Where a decision depends on user/product direction, write an evidence-based proposal and mark the task blocked instead of inventing a decision.

## Task ownership and collaboration

- Select work from BOT_TASK_BOARD.md. Check for an existing task, issue, branch or PR before creating a duplicate.
- Coordinate file ownership before editing. Do not assume another bot has completed work simply because a branch exists.
- Suggested specialist roles are recommendations, not real assignments. Do not claim a bot has been assigned unless an actual assignment or handoff exists.
- Claim or coordinate the task and exact file ownership before editing; change only files required for the assigned objective. If no assignment system exists, coordinate through the task board, issue or PR and never imply a bot was assigned without confirmation.
- Prefer one coherent, testable objective per PR. Avoid parallel edits to the same scenes, scripts, settings or resource paths.
- Inspect incoming contributions, licenses, tests and dependencies before integrating them.
- Use issues and PR discussions for decisions that affect other contributors. Keep the task board synchronized.

## Research standards

For substantial mechanics, algorithms, architecture changes or UX decisions:

- Research multiple sources, comparing large/commercial games with small/independent/open-source examples where relevant.
- Check official Godot 4.7 documentation for engine behavior.
- Include postmortems, technical talks, public implementations or reliable testing references where useful.
- Record source URLs, date checked, scale/context, the relevant observation, fit for LatchPoint, what was adopted/rejected, and license/attribution requirements in RESEARCH_REGISTER.md.
- Distinguish observed facts from your own recommendations.
- Do not copy protected code, art, music, characters, text or level designs. Verify licenses before reusing any source or asset.

## Code, scenes, paths and assets

- GDScript is the default for gameplay. Use C#, GDExtension or other technologies only when a concrete integration, tooling or measured performance requirement justifies their complexity.
- Read the complete affected scripts, scenes and resources before editing.
- Maintain the scene/resource dependency graph: paths, UIDs, script attachments, signals, node paths, groups, input actions, autoloads, import metadata and export references.
- Preserve stable Godot UIDs. Do not edit UID sidecars by hand or remove them casually.
- Check exact path casing; CI may run on a case-sensitive Linux filesystem.
- When moving a file, update every reference in scenes, scripts, resources, configuration, tests, CI and documentation.
- Keep .uid and .import sidecars with their source files when required.
- Keep tests in the tests area and out of shipping scenes unless the test explicitly needs a fixture scene.
- Never commit .godot caches, local editor state, personal machine paths, credentials, secrets, exports or temporary debug artifacts.
- Every retained file must have a clear purpose. If usage is uncertain, investigate and document it; do not delete it to make the tree look clean.

## Implementation and verification

For each change, define:

- Problem and evidence.
- Player or engineering value.
- Scope and explicit non-goals.
- Dependencies and affected files.
- Acceptance criteria.
- Regression cases and test plan.
- Performance implications and rollback approach.

Run the most relevant checks available, including:

- Godot 4.7 headless resource import.
- GDScript parse checks.
- Important scene/resource load checks.
- Unit and integration tests.
- Physics and collision scenarios for any affected bodies, shapes, layers or masks.
- Boot/menu/scene-transition checks.
- CI and export checks when configured.

Physics work must be tested in repeatable scenarios. Cover floor, wall, ceiling, corners, slopes, one-way/moving platforms, high-speed movement, spawn overlap, trigger entry/exit, multiple overlaps, pickup-once behavior, damage, cooldowns and power-up expiry as those systems are implemented.

Machine-learning-assisted playtesting may be used only when a measurable objective and reliable state/action interface exist. Do not call random fuzzing or a hand-written heuristic machine learning. Record seeds, traces and reproducible failures. Never claim runtime execution, model training, export or a passing test without evidence.

If the runtime or a tool is unavailable, state what was not tested and leave the verification pending.

## Git and pull requests

- Never commit directly to main.
- Use focused, descriptive feature/fix/docs branches.
- Never force-push or rewrite shared history.
- Do not merge another contributor's or bot's PR unless the repository owner explicitly authorizes you to do so. Do not edit or commit directly to `main`; use a focused branch and reviewable PR.
- Inspect active branches and PR dependency chains before changing them.
- Do not overwrite another contributor's branch.
- Keep uncertain or unverified changes in a draft PR.
- Do not merge a PR merely because a workflow exits with code zero; inspect warnings, error output and test assertions.
- PR descriptions must state purpose, files changed, references/resources updated, tests actually run, limitations, risks and rollback instructions.

## Documentation and close-out

Update only the documents affected by your task:

- BOT_TASK_BOARD.md — status, scope, dependencies, branch and PR.
- ISSUE_REGISTER.md — confirmed issues, evidence, reproduction and resolution.
- IMPROVEMENT_BACKLOG.md — future work and priorities.
- RESEARCH_REGISTER.md — research evidence and decisions.
- IMPROVEMENT_LOG.md — completed implementation and tests.
- DAILY_QA_LOG.md — repository-level quality audit.
- ARCHITECTURE.md / FILE_STRUCTURE.md — only when architecture or file layout changes.

Every handoff must identify the next owner role or suggested specialist, exact paths to inspect, expected outcome, acceptance criteria and tests. Do not invent real bot identities.

## Definition of done

A task is complete only when its implementation is integrated, references are valid, tests are run and honestly reported, known issues are recorded, documentation is current, the branch is pushed successfully, and a reviewable PR or explicit no-change report exists. A green CI badge alone is not a complete definition of done.
