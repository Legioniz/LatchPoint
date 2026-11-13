# LatchPoint — Issue Register

**Reviewed:** 2026-11-13  
This register separates confirmed defects from missing features, design decisions and investigations. Do not report a hypothesis as a root cause. Link to GitHub issues when they exist.

## P1 — Confirmed investigation

### LP-ISSUE-001: MP3 playback resources retained after physics smoke test

- **Status:** Open; tracked by [GitHub issue #3](https://github.com/Legioniz/LatchPoint/issues/3). The failure is no longer reproduced on the current PR #8 head, but the fix is not integrated into main.
- **Original evidence:** [Workflow run 42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526), job “Import, parse, smoke test and boot”, reported two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 references and `res://Project_bullshit.mp3` after the physics smoke test.
- **Latest branch evidence:** Godot 4.7.2 [workflow run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) passed on `fix/audio-mix-cycle-boot-smoke-shutdown` at `31ada925876e611b02b6ec2f6830cf5f7b932a27`. The full job log contains successful physics and boot smoke-test messages, with no matching ObjectDB/MP3-retention warnings. The physics process observed an AudioServer mix reset after 11 process frames; the boot process observed one after 2 frames, followed by two additional process frames.
- **Current test behavior:** The smoke tests stop the Audio autoload's player, clear its stream, wait for an observable AudioServer mix-cycle reset, and allow deferred main-thread cleanup frames.
- **Root cause:** The branch evidence supports an asynchronous audio-cleanup timing explanation, but the exact engine/project lifecycle cause has not been conclusively isolated. Do not state that the engine itself is defective.
- **Affected areas:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, `tests/boot_smoke_test.gd`, Godot audio lifecycle.
- **Acceptance:** Integrate the dependent PR stack, rerun Godot 4.7.2 validation on the integrated head, inspect both complete smoke-test logs for retained playback resources, and retain the regression checks. Keep this issue open until that integration evidence exists.
- **Safety:** Do not suppress logs, remove music checks or weaken physics assertions.

## P0 — Product decision needed

### LP-DES-001: Definitive game loop and design pillars are not established

- **Status:** Blocked on user/product-owner decision.
- **Evidence:** Current README and development playbook describe an early 2D prototype whose core loop is still being established. PR #9 adds a neutral comparison of authored course surprise, precision movement challenge and compact exploration; it does not select a direction.
- **Risk:** Large feature decisions could build the wrong game.
- **Action:** Confirm the player promise, repeatable core loop, win/fail states, progression and first playable milestone before expanding major mechanics.

## P1 — Integration gate

### LP-INT-001: Foundation changes are staged across dependent draft PRs

- **Status:** Open / in review; integration is blocked by a stale foundation PR base and an unrepresented parent branch.
- **Current main:** `cc7b304d9636353c5de1a056955bd24168a4906c`.
- **Foundation PR:** [PR #1](https://github.com/Legioniz/LatchPoint/pull/1) records base SHA `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`, head `58310c34342eed3bbe7b80cf3e2c9fd253acb566`, and GitHub reports `mergeable=false`. Commit comparison reports 52 commits ahead and 5 behind current main. No rebase, force-push or branch update has been performed.
- **Missing parent:** [PR #6](https://github.com/Legioniz/LatchPoint/pull/6) targets `feature/player-movement-regression-tests`; that branch is 25 commits ahead of `feature/gameplay-foundation`, but no PR with it as head appeared in the current all-state PR inventory.
- **Current dependent PRs:** [#2](https://github.com/Legioniz/LatchPoint/pull/2), [#4](https://github.com/Legioniz/LatchPoint/pull/4), [#5](https://github.com/Legioniz/LatchPoint/pull/5), [#6](https://github.com/Legioniz/LatchPoint/pull/6), [#7](https://github.com/Legioniz/LatchPoint/pull/7), [#8](https://github.com/Legioniz/LatchPoint/pull/8), and [#9](https://github.com/Legioniz/LatchPoint/pull/9) remain open/draft. Their bases form separate feature and documentation stacks; verify live SHAs before any integration.
- **CI trigger gap:** Inspected workflow variants push only on `main` and `feature/**`, or on those branches plus `fix/**`; all inspected pull-request filters target only `main`, and none includes `docs/**` in push filters. Docs branches and stacked PRs targeting non-main branches therefore lack automatic validation triggers.
- **Risk:** Main still represents the older project state. Downstream branches must not be merged out of order or treated as integrated fixes.
- **Action:** Reconcile PR #1 with current main using a reviewed non-destructive branch update; recover/review the movement-regression parent; correct workflow trigger coverage; then review each dependent diff, checks and manual-test limitations. Do not merge without review and explicit project-owner approval.

## P2 — Incomplete coverage or manual verification

### LP-QA-002: Physics test coverage is still limited

- **Status:** Open backlog item; PR #7 adds a current-scene static-platform layer/player-mask assertion but broader coverage remains incomplete.
- **Evidence:** The current smoke test exercises player landing, movement and floor/wall/ceiling probes. It does not yet cover corners, slopes, one-way platforms, moving platforms, high-speed gameplay movement, spawn/respawn overlap, or frame-rate consistency.
- **Action:** Add deterministic, reproducible scenarios as those mechanics enter the game. Test actual gameplay objects in addition to generic probes.

### LP-UI-001: Native display behavior requires desktop verification

- **Status:** Manual verification pending.
- **Evidence:** Headless regression asserts the borderless flag, but the headless DisplayServer does not reliably expose native window mode and title-bar behavior.
- **Action:** Verify fullscreen/windowed transitions and native decorations on supported desktop platforms and record environment details.

### LP-AUD-001: Additional audio files need purpose and license confirmation

- **Status:** Investigation required; do not delete.
- **Evidence:** The tree contains `Tung.mp3`, `maj.mp3` and `yi.mp3` with import sidecars. The inspected Audio autoload references `Project_bullshit.mp3`; no purpose or license record for the other tracks was found in the inspected documentation.
- **Action:** Search all branches, scenes, scripts, dynamic loaders and commit history; ask the asset owner where necessary; record license/source and intended use. Remove only after usage and ownership are verified.

### LP-SET-001: Persist audio and fullscreen settings

- **Status:** Implemented and automated-tested on [PR #6](https://github.com/Legioniz/LatchPoint/pull/6), but not integrated into main. Manual desktop restart/fullscreen verification remains pending.
- **Evidence:** PR #6 adds the Settings autoload, validated ConfigFile persistence and boot-smoke coverage for defaults, round trips, invalid-value recovery and Audio integration. The feature remains in a downstream draft stack.
- **Action:** Review and integrate only after the movement-regression parent and earlier foundation dependencies are settled. Complete native desktop restart/fullscreen verification separately.

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
