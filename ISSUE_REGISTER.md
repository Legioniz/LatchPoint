# LatchPoint — Issue Register

**Reviewed:** 2026-11-14  
This register separates confirmed defects from missing features, design decisions and investigations. Do not report a hypothesis as a root cause. Link to GitHub issues when they exist.

## P1 — Confirmed investigation

### LP-ISSUE-001: MP3 playback resources retained after smoke-test shutdown

- **Status:** Open; tracked by [GitHub issue #3](https://github.com/Legioniz/LatchPoint/issues/3). The warning is clean on the current PR #8 head but is reproduced on the separate foundation/CI PR #11 line.
- **Original evidence:** [Run 42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526) reported two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 references and `res://Project_bullshit.mp3` after the physics smoke test.
- **Clean downstream evidence:** Godot 4.7.2 [run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) on `fix/audio-mix-cycle-boot-smoke-shutdown` at `31ada925876e611b02b6ec2f6830cf5f7b932a27` completed successfully. The full 490-line job log shows a mix reset after 11 process frames for physics and 2 frames for boot, with no matching ObjectDB/resource/MP3 warnings or Godot ERROR/WARNING lines.
- **Current reproduced evidence:** Godot 4.7.2 [push run 43570349587](https://github.com/Legioniz/LatchPoint/actions/runs/43570349587) and [pull-request run 43570448230](https://github.com/Legioniz/LatchPoint/actions/runs/43570448230) on `ci/branch-wide-godot-validation` at `3988d9cf13e5d8912451bbb426e8d4f9a9742f23` both completed successfully but their full logs report the same retained MP3/ObjectDB warnings after both smoke-test processes.
- **Observed output:** `2 ObjectDB instances were leaked at exit`; `1 resources still in use at exit`; retained `AudioStreamPlaybackMP3` and `AudioStreamMP3`; resource `res://Project_bullshit.mp3`.
- **Root cause:** Not proven. The clean branch's mix-cycle diagnostic supports an asynchronous cleanup timing explanation, but the current foundation line still reproduces the warning. Do not attribute it conclusively to Godot or the project without further isolation.
- **Affected areas:** `AUDIO.gd`, `tests/physics_smoke_test.gd`, `tests/boot_smoke_test.gd`, Godot AudioServer lifecycle and the stacked PR integration path.
- **Acceptance:** Integrate the clean shutdown implementation with the current settings/physics/CI stack, run Godot 4.7.2 on the resulting integrated head, and inspect both complete smoke-test logs for retained playback resources. Keep the issue open until then.
- **Safety:** Do not suppress logs, remove music checks or weaken physics assertions.

## P0 — Product decision needed

### LP-DES-001: Definitive game loop and design pillars are not established

- **Status:** Blocked on user/product-owner decision.
- **Evidence:** Current README and development playbook describe an early 2D prototype whose core loop is still being established. PR #9 adds a neutral comparison of authored course surprise, precision movement challenge and compact exploration; it does not select a direction.
- **Risk:** Large feature decisions could build the wrong game.
- **Action:** Confirm the player promise, repeatable core loop, win/fail states, progression and first playable milestone before expanding major mechanics.

## P1 — Integration gate

### LP-INT-001: Foundation changes are staged across dependent draft PRs

- **Status:** Open / in review; integration is blocked by a stale foundation PR base, an unrepresented parent branch and divergent CI workflow changes.
- **Current main:** `097da44e4ad3fb2a3f1e762034855ef46cffdac4`.
- **Foundation PR:** [PR #1](https://github.com/Legioniz/LatchPoint/pull/1) has base SHA `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74` and head `58310c34342eed3bbe7b80cf3e2c9fd253acb566`. GitHub reports `mergeable=false` / `dirty`; comparison is 52 commits ahead and 9 behind current main. Main and the PR independently add `README.md`, so reconcile the add/add content. Do not rebase, force-push or update the branch without a reviewed plan.
- **Missing parent:** [PR #6](https://github.com/Legioniz/LatchPoint/pull/6) targets `feature/player-movement-regression-tests`; that branch is 25 commits ahead of `feature/gameplay-foundation`, but no PR with it as head appears in the current PR inventory. Recover/review its intended integration path before integrating PR #6 or descendants.
- **Current feature PR relationships:** [#2](https://github.com/Legioniz/LatchPoint/pull/2) targets `feature/gameplay-foundation`; [#4](https://github.com/Legioniz/LatchPoint/pull/4) targets `fix/windowed-borderless-toggle`; [#6](https://github.com/Legioniz/LatchPoint/pull/6) targets the unrepresented movement-regression parent; [#7](https://github.com/Legioniz/LatchPoint/pull/7) targets `feature/settings-persistence`; [#8](https://github.com/Legioniz/LatchPoint/pull/8) targets `feature/physics-layer-mask-regressions`. The ten PRs #1, #2, #4, #5, #6, #7, #8, #9, #10 and #11 remain open/draft; no review comments or approvals were found.
- **Documentation PR relationships:** [PR #5](https://github.com/Legioniz/LatchPoint/pull/5) adds the shared contributor docs to the foundation line; [PR #9](https://github.com/Legioniz/LatchPoint/pull/9) adds core-loop research on the docs line; [PR #10](https://github.com/Legioniz/LatchPoint/pull/10) records daily QA on top of PR #9.
- **CI workflow PR:** [PR #11](https://github.com/Legioniz/LatchPoint/pull/11) targets `feature/gameplay-foundation` from `ci/branch-wide-godot-validation`. Its catch-all branch filters and pinned Node 24-compatible actions pass its own push and PR runs, but the workflow is not yet propagated to other feature/docs descendants. Their current workflow files still use prefix filters and `pull_request: branches: [main]`; preserve PR #11's policy when reconciling the stack.
- **Risk:** Main still represents the older prototype state. The clean audio fix and settings/physics changes remain staged on separate downstream branches. A green workflow exit does not prove clean audio shutdown while the full logs still show retained resources.
- **Action:** Confirm repository access policy and main branch protection; reconcile PR #1 with current main without rewriting history; recover/review the movement-regression parent; preserve PR #11's catch-all workflow and pinned actions across descendants; then review each dependent diff and rerun integrated checks. Do not merge without explicit project-owner approval.

## P1 — Repository access and branch protection

### LP-SEC-001: Repository visibility and main protection need owner confirmation

- **Status:** Owner confirmation required; no GitHub settings were changed.
- **Evidence:** Repository metadata reports visibility `public`; the project request describes LatchPoint as private. GitHub reports `main` and all inspected branches as unprotected. The current copyright notice explicitly acknowledges GitHub's platform-specific viewing/forking permissions while the repository is public.
- **Risk:** If private access is intended, the source is publicly viewable/forkable; a proprietary notice does not make a repository private. An unprotected main branch also does not enforce the required PR-only integration process.
- **Action:** Confirm whether public visibility is intentional. If private is intended, change repository visibility and review collaborators/forks. In either case, protect main with PR requirements and the required CI checks. Do not change visibility or protection without owner authorization.

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

## P3 — Repository hygiene and contributor documentation

### LP-ARCH-001: Directory naming is inconsistent

- **Status:** Improvement proposal, not a runtime bug.
- **Evidence:** Existing source directories include `Asset/` and `Scene/`, while tests are in `tests/` and several scripts are at the root.
- **Action:** Keep current paths stable. Consider a single planned migration only after the foundation PR chain settles and every UID/resource reference is mapped.

### LP-DOC-002: Testing guide is missing from the shared documentation PR line

- **Status:** Proposed; no files copied or moved.
- **Evidence:** `TESTING_GUIDE.md` exists on `feature/physics-layer-mask-regressions` and `fix/audio-mix-cycle-boot-smoke-shutdown`, but it is absent from the `docs/core-loop-reference-research` base used by PR #10. The shared `AGENTS.md` correctly says to read the guide when present.
- **Action:** After the feature/test stack settles, bring the current guide into the shared documentation line, ensure it matches the integrated tests/settings/audio lifecycle, and link it from the README/AGENTS guide. Do not copy an older guide blindly.

### LP-REPO-001: Copied Git metadata remains on legacy repository refs

- **Status:** Investigation required; no branch or file was deleted.
- **Evidence:** Main still contains copied Git `config`, `description` and binary `index` files; PR #1 deletes those from its proposed foundation tree. The unassociated `automation/playability-baseline` branch remains at the original baseline commit and contains tracked `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD`.
- **Action:** Preserve the existing PR #1 cleanup on its branch. Separately confirm whether the old automation branch is still needed before removing any tracked metadata or deleting the branch. Do not rewrite or delete the branch as part of routine cleanup.

## Resolved on the foundation branch — pending merge into main

The following defects are addressed in the open foundation PR work, but should not be treated as fixed on main until the relevant changes are merged:

- Missing gameplay background asset reference replaced with a temporary ColorRect fallback.
- Audio autoload path corrected to the committed root-level MP3 and its import sidecar source path updated.
- Pause-menu callback/missing exit-script integration consolidated.
- New Game scene routing fixed and Load Game disabled pending save support.
- Root-level copied Git metadata and confirmed unused prototype files removed after reference checks.
- Player horizontal velocity calculations consolidated into one acceleration/friction model.

Verify current branch state and PR review before closing any related issue.
