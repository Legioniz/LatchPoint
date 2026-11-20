# LatchPoint — Issue Register

**Reviewed:** 2026-11-19  
This register separates confirmed defects from missing features, design decisions and investigations. Do not report a hypothesis as a root cause. Link to GitHub issues when they exist.

## P1 — Confirmed investigation

### LP-ISSUE-001: MP3 playback resources retained after smoke-test shutdown

- **Status:** Open; tracked by [GitHub issue #3](https://github.com/Legioniz/LatchPoint/issues/3). PR #8 and the newer PR #14 shared-verifier head have clean downstream branch-head results, but the warning remains reproduced on other unintegrated branches and no integrated main/CI/sidecar/high-speed head has been verified.
- **Original evidence:** [Run 42573252526](https://github.com/Legioniz/LatchPoint/actions/runs/42573252526) reported two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 references and res://Project_bullshit.mp3 after the physics smoke test.
- **Clean downstream evidence:** Godot 4.7.2 [run 43175060644](https://github.com/Legioniz/LatchPoint/actions/runs/43175060644) on fix/audio-mix-cycle-boot-smoke-shutdown at 31ada925876e611b02b6ec2f6830cf5f7b932a27 completed successfully. The full 490-line job log shows a mix reset after 11 process frames for physics and 2 frames for boot, with no matching ObjectDB/resource/MP3 warnings or Godot ERROR/WARNING lines.
- **Reproduced evidence:** Godot 4.7.2 [run 43570349587](https://github.com/Legioniz/LatchPoint/actions/runs/43570349587) and [run 43570448230](https://github.com/Legioniz/LatchPoint/actions/runs/43570448230) on ci/branch-wide-godot-validation, plus [run 43687899303](https://github.com/Legioniz/LatchPoint/actions/runs/43687899303) on PR #12, completed their workflow steps but reported retained MP3/ObjectDB warnings after both smoke-test processes.
- **Latest evidence (2026-11-17):** Godot 4.7.2 [branch-head run 44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467) on PR #13's feature/high-speed-collision-regressions head passed import, tracked-GDScript parsing, physics smoke and boot smoke. The physics process then reported two leaked ObjectDB instances, one resource still in use, retained AudioStreamPlaybackMP3 / AudioStreamMP3 for res://Project_bullshit.mp3, and an orphan Music StringName. The separate boot process passed without matching shutdown warnings. The workflow also emitted the Node.js 20 deprecation warning for actions/checkout@v4.
- **Latest evidence (2026-11-19 review):** PR #14 [shared audio shutdown verifier](https://github.com/Legioniz/LatchPoint/pull/14), head 78f8097326607beaab4ad08dbc2a93ac0fb0fe14, is open/draft on top of PR #8's fix/audio-mix-cycle-boot-smoke-shutdown branch. Godot 4.7.2 push run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262) passed import, tracked-GDScript parsing, physics smoke and boot smoke. The complete 494-line log records the Dummy-driver mix reset after 12 physics process frames and 3 boot process frames at 44,100 Hz, with no ObjectDB/resource/MP3/StringName diagnostics or Godot ERROR/WARNING lines after either process. The only warning is the inherited Node.js 20 deprecation for actions/checkout@v4. This is clean downstream evidence, not an integrated main/PR #11/#12/#13 result; keep issue #3 open until the dependent stack is reconciled and retested.
- **Observed output:** 2 ObjectDB instances were leaked at exit; 1 resource remained in use; retained AudioStreamPlaybackMP3 and AudioStreamMP3; resource res://Project_bullshit.mp3; orphan Music StringName.
- **Root cause:** Not proven. The clean branch's mix-cycle diagnostic supports an asynchronous cleanup timing explanation, but other active branch lines still reproduce the warning. Do not attribute it conclusively to Godot or the project without further isolation.
- **Affected areas:** AUDIO.gd, tests/physics_smoke_test.gd, tests/boot_smoke_test.gd, Godot AudioServer lifecycle and the stacked PR integration path.
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

- **Status:** Open / in review; integration is blocked by a stale foundation PR base, an unrepresented movement-regression parent and divergent CI workflow changes.
- **Current main:** 097da44e4ad3fb2a3f1e762034855ef46cffdac4; its recursive tree has 72 entries. The current branch inventory has 20 refs and the open-PR inventory has 13 draft PRs.
- **Foundation PR:** [PR #1](https://github.com/Legioniz/LatchPoint/pull/1) has base SHA f7bb59d9ef9385a9f62c12c68b32d4ca11328f74 and head 58310c34342eed3bbe7b80cf3e2c9fd253acb566. GitHub reports mergeable=false / dirty; comparison is 52 commits ahead and 9 behind current main. Main and the PR independently add README.md, so reconcile the add/add content. Do not rebase, force-push or update the branch without a reviewed plan.
- **Missing parent:** [PR #6](https://github.com/Legioniz/LatchPoint/pull/6) and [PR #13](https://github.com/Legioniz/LatchPoint/pull/13) target feature/player-movement-regression-tests. That branch is 25 commits ahead of feature/gameplay-foundation, but no PR with it as head appears in the current PR inventory. Recover/review its intended integration path before integrating PR #6 or #13 descendants.
- **PR #13 high-speed test branch:** [PR #13](https://github.com/Legioniz/LatchPoint/pull/13) is open/draft and mergeable, with base feature/player-movement-regression-tests, head feature/high-speed-collision-regressions, and head SHA 066cdded1486072e229ae52449b3ca858211912e. It adds five commits across five files (88 additions, 6 deletions). Comparing its head with main reports 82 commits ahead and 9 behind; this is a stacked test-only change, not a main-ready branch.
- **Unrepresented audio experiment:** fix/audio-shutdown-grace-experiment remains four commits ahead of fix/windowed-borderless-toggle; no current PR uses it as head. Preserve it as unreviewed historical work.
- **Current feature PR relationships:** PR #2 targets feature/gameplay-foundation; PR #4 targets fix/windowed-borderless-toggle; PR #6 targets the unrepresented movement-regression parent; PR #7 targets feature/settings-persistence; PR #8 targets feature/physics-layer-mask-regressions; PR #13 targets the same unrepresented movement-regression parent; PR #14 is stacked on PR #8's audio-shutdown branch.
- **Documentation PR relationships:** [PR #5](https://github.com/Legioniz/LatchPoint/pull/5) adds shared contributor docs to the foundation line; [PR #9](https://github.com/Legioniz/LatchPoint/pull/9) adds core-loop research on the docs line; [PR #10](https://github.com/Legioniz/LatchPoint/pull/10) records daily QA on top of PR #9.
- **CI workflow PR:** [PR #11](https://github.com/Legioniz/LatchPoint/pull/11) targets feature/gameplay-foundation from ci/branch-wide-godot-validation. Its catch-all branch filters and pinned Node 24-compatible actions pass its own runs, but the workflow is not propagated to the movement/test descendants. PR #13's run [44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467) still uses actions/checkout@v4 and emits the Node.js 20 deprecation warning.
- **Audio import sidecar PR:** [PR #12](https://github.com/Legioniz/LatchPoint/pull/12) targets feature/gameplay-foundation; its sidecar corrections remain unintegrated into main.
- **Risk:** Main still represents the older prototype. PR #14 now has a clean full-log result on the PR #8 audio-shutdown stack, but PR #11/#12/#13 retain separate CI/workflow/test lines and no integrated head has been verified. A green process exit alone does not prove clean shutdown; inspect complete process logs.
- **Action:** Confirm repository access policy and main branch protection; reconcile PR #1 with current main without rewriting history; recover/review the movement-regression parent; preserve PR #11's workflow policy across descendants; then review dependent diffs and rerun integrated checks. Do not merge without explicit project-owner approval.

## P1 — Repository access and branch protection

### LP-SEC-001: Repository visibility and main protection need owner confirmation

- **Status:** Owner confirmation required; no GitHub settings were changed.
- **Evidence:** Repository metadata still reports visibility `public`; the project request describes LatchPoint as private. The previous audit reported `main` and all inspected branches as unprotected. On this recheck, the branch-protection endpoint returned HTTP 403 (`Resource not accessible by integration`), so current protection rules could not be independently re-read. The current copyright notice explicitly acknowledges GitHub's platform-specific viewing/forking permissions while the repository is public.
- **Risk:** If private access is intended, the source is publicly viewable/forkable; a proprietary notice does not make a repository private. An unprotected main branch also does not enforce the required PR-only integration process.
- **Action:** Confirm whether public visibility is intentional. If private is intended, change repository visibility and review collaborators/forks. In either case, protect main with PR requirements and the required CI checks. Do not change visibility or protection without owner authorization.

## P2 — Incomplete coverage or manual verification

### LP-IMP-001: MP3 import sidecars reference a missing MUSIC directory on main

- **Priority:** P2
- **Status:** In review on the foundation/sidecar draft PRs; not integrated into main.
- **Evidence:** The complete main tree has four MP3 source files at the repository root and no `MUSIC/` directory. Direct inspection of `Tung.mp3.import`, `maj.mp3.import`, `yi.mp3.import` and `Project_bullshit.mp3.import` on main shows `source_file="res://MUSIC/<filename>.mp3"` for all four. The corresponding source files exist at `res://<filename>.mp3`.
- **Affected files:** The four MP3 `.import` sidecars and their source MP3 files; `tests/physics_smoke_test.gd` on the sidecar branch.
- **Current proposed repair:** PR #1 corrects the `Project_bullshit.mp3.import` source path. PR #12 corrects the other three source paths and adds a ConfigFile/source-existence assertion for all four sidecars. On `feature/audio-import-sidecar-validation`, direct inspection confirms the four `source_file` values now point to their root-level sources.
- **Acceptance:** Integrate both path corrections without changing MP3 binaries, UIDs, import destinations or import parameters; run Godot 4.7.2 import, tracked-script parsing and the four-sidecar regression check on the integrated branch; inspect the full logs. Keep the task open until the corrected paths reach main.
- **Related task/PRs:** [LP-AUD-002](https://github.com/Legioniz/LatchPoint/pull/12) / [PR #1](https://github.com/Legioniz/LatchPoint/pull/1) / [PR #12](https://github.com/Legioniz/LatchPoint/pull/12).

### LP-QA-002: Physics test coverage is still limited

- **Status:** Open; PR #7 adds the current-scene static-platform layer/player-mask assertion and PR #13 adds test-only high-speed floor/wall/ceiling probes. Broader gameplay coverage remains incomplete.
- **Evidence:** PR #13 uses a synthetic CharacterBody2D with a 20×20 probe against 20-pixel-thick floor, wall and ceiling fixtures. Its velocity is derived from the configured physics tick rate to move 100 pixels per physics tick (6,000 pixels/second at 60 Hz). It asserts the expected is_on_floor(), is_on_wall() or is_on_ceiling() classification and non-penetration. Godot 4.7.2 [run 44035218467](https://github.com/Legioniz/LatchPoint/actions/runs/44035218467) passed the smoke test. This is an engine/fixture regression, not a high-speed test of the shipping player.
- **Remaining untested cases:** corners, slopes, one-way platforms, moving platforms, actual-player high-speed movement, spawn/respawn overlap and frame-rate consistency. Hazard, pickup, projectile and power-up tests are not applicable until those systems exist.
- **Action:** Add deterministic scenarios as mechanics and intended movement rules are confirmed. Test real gameplay objects where applicable; do not treat generic probes as proof of all collision behavior.

### LP-UI-001: Native display behavior requires desktop verification

- **Status:** Manual verification pending.
- **Evidence:** Headless regression asserts the borderless flag, but the headless DisplayServer does not reliably expose native window mode and title-bar behavior.
- **Action:** Verify fullscreen/windowed transitions and native decorations on supported desktop platforms and record environment details.

### LP-AUD-001: Additional audio files need purpose and license confirmation

- **Status:** Partial repository audit completed 2026-11-17; source, rights holder, permission and intended use remain unverified. Do not delete or claim ownership.
- **Evidence:** Main contains `Tung.mp3`, `maj.mp3` and `yi.mp3` with import sidecars. Default-branch code search found only the sidecars for those three tracks; `AUDIO.gd` references `Project_bullshit.mp3`. This does not prove absence of dynamic references or references on every branch. All four MP3s were added in commit [8e586c1](https://github.com/Legioniz/LatchPoint/commit/8e586c1eb3c52f11b5c5167355e663587363d245) on 2026-08-23 by `Codfyyy` with the generic message “Add files via upload”; no source, license or attribution is recorded in that commit. The current proprietary `LICENSE` says third-party audio remains governed by its own terms; it does not establish rights in these files. The separate import-path repair is tracked by LP-IMP-001 / PR #12 and does not resolve licensing.
- **Action:** Ask the asset owner to identify the source, rights holder, intended use and applicable license/permission for each file. Complete a branch-wide scene/script/dynamic-loader search before classifying the other three as unused. Keep the files unchanged until usage and rights are confirmed; do not redistribute them on an assumption of ownership.

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

- **Status:** Investigated on 2026-11-16; no branch or file was changed. Historical ref retained pending owner direction.
- **Evidence:** `automation/playability-baseline` points to `f7bb59d9ef9385a9f62c12c68b32d4ca11328f74`. GitHub compare against current `main` reports zero commits ahead and nine behind; its head is the merge base of PR #1. None of the 11 current PRs uses this branch as base or head.
- **Tracked root-level files inspected on the branch:** `COMMIT_EDITMSG` (contains `Initial commit`), `FETCH_HEAD` (former Codfyyy/Latchpoint- remote URL and fetched commit), `HEAD` (contains `ref: refs/heads/main`), `config` (former remote URL; no credential in the inspected text), `description` (generic placeholder), and binary `index` (present; not decoded).
- **Main-branch history:** commit [9ce61c5](https://github.com/Legioniz/LatchPoint/commit/9ce61c5e014927aa3c90a14a0ea941e98823d42b) removed `COMMIT_EDITMSG`, `FETCH_HEAD` and `HEAD` from main. Main still tracks `config`, `description` and binary `index`; PR #1 already proposes removing those three files from its foundation branch.
- **Technical classification:** Git's documented repository layout places active `HEAD`, `config` and `index` under `$GIT_DIR`; `FETCH_HEAD` and `COMMIT_EDITMSG` are likewise documented as `.git/FETCH_HEAD` and `$GIT_DIR/COMMIT_EDITMSG`. These copies are at the project root, so they are tracked project blobs rather than active metadata for the hosted repository. The binary index was not decoded, so no claim is made about its internal entries.
- **Disposition:** Preserve the stale automation branch as a historical baseline and PR #1 merge-base reference. Do not delete the branch, edit its files, rewrite history, or duplicate PR #1's cleanup without explicit owner direction. No credential was observed in the inspected text files.
- **Remaining action:** Owner confirmation is required only if the branch should later be archived or deleted. The investigation itself is complete; no runtime defect or Godot test is implicated.

## Resolved on the foundation branch — pending merge into main

The following defects are addressed in the open foundation PR work, but should not be treated as fixed on main until the relevant changes are merged:

- Missing gameplay background asset reference replaced with a temporary ColorRect fallback.
- Audio autoload path corrected to the committed root-level MP3 and its import sidecar source path updated.
- Pause-menu callback/missing exit-script integration consolidated.
- New Game scene routing fixed and Load Game disabled pending save support.
- Root-level copied Git metadata and confirmed unused prototype files removed after reference checks.
- Player horizontal velocity calculations consolidated into one acceleration/friction model.

Verify current branch state and PR review before closing any related issue.

## 2026-11-20 — LP-ISSUE-001 / GitHub issue #3 cross-branch evidence

- PR #14 shared-verifier head and PR #15 settings-lifecycle head use the same `AUDIO.gd` blob SHA: `bbfc914556569a979a71c3a313cb4fbb97829509`.
- PR #14 physics test waits for an observable AudioServer mix-age reset (12 process frames in run [44255399262](https://github.com/Legioniz/LatchPoint/actions/runs/44255399262)) and then two cleanup frames. Both smoke-process logs have no matching ObjectDB/resource/MP3/StringName shutdown diagnostics.
- PR #15 physics test waits only two process frames after `shutdown_audio()`; run [44478777582](https://github.com/Legioniz/LatchPoint/actions/runs/44478777582) reports 2 leaked ObjectDB instances, one retained MP3 playback/stream resource at `res://Project_bullshit.mp3`, and an unclaimed `Music` StringName after physics. The boot process runs 120 frames before shutdown and has no matching diagnostics.
- Current interpretation: insufficient test-harness mix/deferred-cleanup synchronization is the strongest immediate explanation. Production ownership and the exact engine-internal cause remain unproven.
- PR #14 and PR #15 heads diverge by 2 ahead / 9 behind from merge base `43eee75ba3d912142b1eccbdd7629a8448f180c4`; do not resolve by force-push or silent retargeting.
- Evidence comment: https://github.com/Legioniz/LatchPoint/issues/3#issuecomment-7027119636
- **Status:** investigation narrowed, not resolved. Keep issue #3 open until both test changes run together on one reviewed integrated head with clean full logs.
