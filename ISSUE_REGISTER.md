# LatchPoint — Issue Register

**Reviewed:** 2026-11-09  
This register separates confirmed defects from missing features, design decisions and investigations. Do not report a hypothesis as a root cause. Link to GitHub issues when they exist.

## P1 — Confirmed investigation

### LP-ISSUE-001: MP3 playback resources retained after physics smoke test

- **Status:** Open; tracked by [GitHub issue #3](https://github.com/Legioniz/LatchPoint/issues/3).
- **Evidence:** [Workflow run 42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526), job “Import, parse, smoke test and boot”.
- **Observed output:** The physics smoke test prints that the scene/physics checks passed. On process shutdown, Godot reports two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 and AudioStreamMP3 references, and the path `res://Project_bullshit.mp3`.
- **Current behavior:** The test calls the Audio autoload's `shutdown_audio()`, stops playback and clears the stream, then waits two process frames.
- **Root cause:** Not proven. Asynchronous AudioServer playback cleanup is a plausible lead but requires a reproducible experiment.
- **Affected areas:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, Godot audio lifecycle.
- **Acceptance:** Reproduce, identify project-owned references versus test/driver/engine lifecycle, add a deterministic regression test where possible, and show clean shutdown or document a verified minimal engine limitation.
- **Safety:** Do not suppress logs, remove music tests or weaken physics assertions.

## P0 — Product decision needed

### LP-DES-001: Definitive game loop and design pillars are not established

- **Status:** Blocked on user/product-owner decision.
- **Evidence:** Current README and development playbook explicitly describe an early 2D prototype whose core loop is still being established.
- **Risk:** Large feature decisions could build the wrong game.
- **Action:** Confirm the player promise, repeatable core loop, win/fail states, progression and first playable milestone before expanding major mechanics.

## P1 — Integration gate

### LP-INT-001: Foundation changes are staged across dependent draft PRs

- **Status:** Open / in review.
- **Evidence:** PR #1 targets main; PR #2 is based on the foundation branch; PR #4 is based on the fullscreen follow-up branch.
- **Risk:** The default branch still represents the older project state until the foundation PR is merged. Downstream branches must not be merged out of order.
- **Action:** Review the complete diff and checks in dependency order. Reconfirm each base/head SHA before merging. Keep the draft state until review and verification are complete.

## P2 — Incomplete coverage or manual verification

### LP-QA-002: Physics test coverage is still limited

- **Status:** Open backlog item.
- **Evidence:** The current smoke test exercises player landing and floor, wall and ceiling probes. It does not yet cover corners, slopes, one-way platforms, moving platforms, high-speed gameplay movement, spawn/respawn overlap, or frame-rate consistency.
- **Action:** Add deterministic, reproducible scenarios as those mechanics enter the game. Test actual gameplay objects in addition to generic probes.

### LP-UI-001: Native display behavior requires desktop verification

- **Status:** Manual verification pending.
- **Evidence:** Headless regression asserts the borderless flag, but the headless DisplayServer does not reliably expose native window mode and title-bar behavior.
- **Action:** Verify fullscreen/windowed transitions and native decorations on supported desktop platforms and record environment details.

### LP-AUD-001: Additional audio files need purpose and license confirmation

- **Status:** Investigation required; do not delete.
- **Evidence:** The tree contains `Tung.mp3`, `maj.mp3` and `yi.mp3` with import sidecars. The inspected Audio autoload references `Project_bullshit.mp3`; no purpose or license record for the other tracks was found in the inspected documentation.
- **Action:** Search all branches, scenes, scripts, dynamic loaders and commit history; ask the asset owner where necessary; record license/source and intended use. Remove only after usage and ownership are verified.

### LP-SET-001: Settings are not persisted across application restarts

- **Status:** Known missing feature, not a regression.
- **Evidence:** The Audio autoload stores volume values in memory. No persistent settings service is present in the reviewed tree.
- **Action:** Design settings persistence with validation and safe defaults. Coordinate with save-system architecture.

### LP-SAVE-001: Save/load is not implemented

- **Status:** Known missing feature, represented honestly in the UI.
- **Evidence:** Load Game is disabled and marked “Coming Soon”; `new_load.gd` does not implement save loading.
- **Action:** Keep disabled until versioned local persistence and recovery are ready.

### LP-ARCH-001: Directory naming is inconsistent

- **Status:** Improvement proposal, not a runtime bug.
- **Evidence:** Existing source directories include `Asset/` and `Scene/`, while tests are in `tests/` and several scripts are at the root.
- **Action:** Keep current paths stable. Consider a single planned migration only after the foundation PR chain settles and every UID/resource reference is mapped.

## Resolved on the foundation branch — pending merge into main

The following defects are addressed in the open foundation PR work, but should not be treated as fixed on main until the relevant changes are merged:

- Missing gameplay background asset reference replaced with a temporary ColorRect fallback.
- Audio autoload path corrected to the committed root-level MP3 and its import sidecar source path updated.
- Pause-menu callback/missing exit-script integration consolidated.
- New Game scene routing fixed and Load Game disabled pending save support.
- Root-level copied Git metadata and confirmed unused prototype files removed after reference checks.
- Player horizontal velocity calculations consolidated into one acceleration/friction model.

Verify current branch state and PR review before closing any related issue.
