# Performance and Programming Language Guidance

> Status: Engineering guidance / proposed direction  
> Project: LATCHPOINT  
> Current engine baseline: Godot 4.7, Forward+ renderer, Jolt Physics  
> Last reviewed: 2026-11-10

## 1. Decision summary

**Keep Godot as the current engine. Do not migrate to Unity or Unreal solely because another language has higher theoretical raw CPU performance.**

The repository currently targets Godot 4.7 and uses the Forward+ renderer and Jolt Physics. A wholesale engine migration introduces implementation, tooling, content, and testing costs. Reconsider the engine only if measured project requirements cannot be met in Godot or a required platform/toolchain is unavailable.

Recommended initial stack:
- **Godot 4.7** for scenes, rendering, physics integration, input, audio, animation, and tooling.
- **GDScript** for ordinary gameplay and iteration, unless the project is already using the .NET build.
- **C# (Godot .NET)** as an optional alternative for larger gameplay systems, strongly typed application logic, and teams that prefer the .NET ecosystem. This requires the .NET-enabled Godot editor/runtime and validated export targets.
- **C++ via GDExtension** only for measured, isolated CPU bottlenecks that cannot be adequately addressed through algorithms, data layout, or built-in engine features.
- **Python** for offline development tools, content validation, probability simulations, balancing, and benchmark analysis—not per-frame gameplay code.

This is a staged architecture, not a requirement to use every language.

## 2. Language comparison

| Language | Runtime performance potential | Memory control | Main trade-off | Recommended role |
|---|---|---|---|---|
| C | Very high | Manual | Low-level safety and development burden | Specialized native libraries |
| C++ | Very high | Manual/RAII | Complexity, build and ABI management | GDExtension/native hotspots |
| Rust | Very high | Ownership model | Smaller Godot integration ecosystem; bindings/toolchain validation | Optional native modules after a prototype |
| C# | High | Managed runtime with low-level options | Runtime/GC behavior must be profiled; Godot .NET deployment constraints | Gameplay/application systems |
| Go | High | Garbage-collected | Not a first-class Godot gameplay scripting path | External tools/services |
| Java | High | Garbage-collected | Limited direct Godot integration for this project | External tools/services |
| Swift | High | Managed/ARC | Platform and engine integration costs | Not recommended as core game language |
| Zig | Very high | Explicit control | Ecosystem and integration maturity | Experimental native modules |
| Lua | Moderate to high, implementation-dependent | Runtime-managed | Requires embedding/integration | Embedded scripting only |
| JavaScript | Runtime-dependent | Runtime-managed | Not a natural fit for native Godot gameplay | Web tooling/prototypes |
| Python | Low for tight real-time loops; excellent tooling ecosystem | Runtime-managed | Interpreter overhead for per-frame work | Offline tools and analysis |
| GDScript | Suitable for normal gameplay; benchmark hot paths | Engine-managed | Dynamic-language overhead in some workloads | Default Godot gameplay scripting |

These are qualitative engineering descriptions, not universal benchmark scores. Compiler, runtime, algorithm, data structures, call frequency, memory allocation, and hardware can change the result dramatically. Do not infer that a language will make the complete game faster without measuring the actual workload.

## 3. Godot-specific options

### GDScript

Use for:
- Scene and node orchestration.
- Player interactions and gameplay state.
- UI, menus, dialogue, quests, and inventory.
- Enemy behavior coordination.
- Prototyping and content-facing logic.

Keep expensive loops bounded. Avoid unnecessary per-frame allocations, repeated scene-tree searches, excessive signal churn, and expensive work in every entity's process or physics-process callback.

### C# with Godot .NET

Consider when:
- The team benefits from static typing and .NET tooling.
- Systems have substantial domain logic or complex data models.
- Existing C# libraries are useful.
- A measured workload benefits from C# implementation or data-oriented design.

Before adopting it, verify:
- The project is opened with the .NET-enabled Godot build.
- Export templates and target platforms support the required .NET deployment.
- CI can install the matching .NET SDK and build/export the project.
- Native interop and engine API calls are not dominating the workload.

Do not assume that rewriting GDScript in C# automatically improves frame rate. Profile both implementations under the same release configuration and workload.

### C++ with GDExtension

Reserve for:
- Proven CPU-heavy algorithms.
- Large-scale procedural calculations.
- Specialized simulation or signal-processing workloads.
- Native libraries that are impractical to reproduce in script.

Costs include native build pipelines, platform-specific binaries, memory ownership, debugging complexity, ABI compatibility, and distribution/testing overhead. Keep the extension boundary narrow and pass batches of data rather than making thousands of tiny script/native calls.

### Rust and other native languages

Rust can provide native performance and strong memory-safety guarantees, but a Godot integration depends on third-party bindings and their compatibility with the target Godot version and platforms. Treat Rust, Zig, and other native-language integrations as experiments until a minimal extension has built, run, exported, and passed CI on every target platform.

## 4. Recommended system allocation

| System | Initial implementation | Escalation path |
|---|---|---|
| Player movement and interaction | GDScript | C# only if justified by architecture or profiling |
| Enemy state machines | GDScript | C# for larger typed domain models |
| Behavior coordination | GDScript | Optimize update frequency and decision scheduling first |
| Pathfinding/navigation | Godot navigation APIs | Custom native algorithm only after profiling |
| Procedural world generation | GDScript orchestration | C# off-thread work or C++ extension for measured hotspots |
| Random events and horror director | GDScript/C# | Optimize scheduling and sampling before native code |
| Probability and balance simulations | Python offline; game-side GDScript/C# | Native batch computation only if runtime needs it |
| Inventory, items, quests, saves | GDScript or C# | Usually no native extension needed |
| UI, dialogue, menus | GDScript | Usually remain in engine scripting |
| Audio and physics | Godot audio/physics systems | Profile configuration and scene complexity first |
| Development utilities | Python | C# or shell tooling if integration requires it |

## 5. Performance engineering rules

1. **Profile before optimizing.** Capture representative scenes and gameplay, not empty test rooms alone.
2. **Set frame-time budgets.** At 60 FPS the total frame budget is about 16.67 ms; at 30 FPS it is about 33.33 ms. Track CPU and GPU frame time separately.
3. **Measure release builds on target hardware.** Editor performance is not a reliable substitute for exported builds.
4. **Optimize algorithms before languages.** Reduce unnecessary work, use spatial partitioning where appropriate, cache stable references, batch operations, and avoid repeated global scans.
5. **Control update frequency.** Distant or inactive AI should not necessarily run full decision logic every frame. Use staggered ticks and event-driven updates where appropriate.
6. **Keep rendering and simulation budgets separate.** Draw calls, overdraw, shadows, lighting, resolution, shader cost, and GPU fill rate can dominate even when scripts are fast.
7. **Watch memory and allocations.** Track peak RAM, resource lifetime, loading spikes, object churn, and garbage-collection pauses where applicable.
8. **Use concurrency deliberately.** Move thread-safe, independent work off the main thread; avoid blocking the main thread while waiting for jobs. Respect Godot's thread-safety rules for scene-tree and rendering APIs.
9. **Avoid premature micro-optimization.** Keep code maintainable until profiling identifies a repeatable bottleneck.
10. **Retest after every optimization.** Keep before/after measurements and verify behavior, determinism, and save compatibility.

## 6. Benchmark protocol

For any proposed language rewrite or native extension:
- Use the same algorithm, input data, scene, hardware, build mode, and target frame rate.
- Test in exported release builds, not only in the editor.
- Warm up the workload where runtime/JIT behavior applies.
- Run repeated trials and compare median and high-percentile frame times.
- Record CPU time, GPU time, peak memory, allocations/GC pauses, and load time.
- Include a realistic worst-case scene: many active enemies, navigation requests, world events, and simultaneous effects.
- Require a measurable improvement large enough to justify added complexity.
- Keep a reproducible benchmark scene/script and record the engine/runtime version.

Suggested initial acceptance targets (adjust to the actual minimum hardware):
- 60 FPS target: sustained frame time at or below 16.67 ms.
- 30 FPS fallback: sustained frame time at or below 33.33 ms.
- Avoid frequent spikes above the selected frame budget during representative gameplay.
- Define explicit RAM and loading-time budgets once target hardware is selected.

These are project targets to validate, not claims about current performance.

## 7. Engine decision matrix

| Engine | Strengths | Costs and considerations | Current recommendation |
|---|---|---|---|
| Godot 4.7 | Lightweight workflow, open source, integrated scene system, GDScript/C#/GDExtension options | Smaller commercial asset ecosystem; .NET and native extensions add deployment complexity | **Stay on current engine and profile** |
| Unity | Mature C# ecosystem, broad asset/plugin ecosystem, Burst/Jobs/DOTS options | Migration and retraining costs; package and pipeline choices need management | Re-evaluate only if project requirements justify migration |
| Unreal Engine | Strong high-end 3D tooling, C++ and Blueprint workflows | Higher project/tooling complexity and potentially heavier hardware/workflow demands | Consider if visual/3D production requirements outgrow current engine |

A different engine is not automatically faster for this game. Rendering configuration, content complexity, physics setup, asset quality, and implementation discipline are major contributors.

## 8. Recommended decision for LATCHPOINT

**Phase 1 — Stabilize Godot baseline**
- Keep Godot 4.7 and current renderer/physics configuration.
- Establish representative benchmark scenes.
- Track CPU/GPU frame time, memory, load times, and worst-case gameplay.

**Phase 2 — Build gameplay with the simplest suitable language**
- Use GDScript for core scene-driven gameplay unless the project has already committed to Godot .NET.
- Keep gameplay systems modular and data-oriented where useful.
- Avoid mixing languages without a concrete reason.

**Phase 3 — Profile and selectively optimize**
- Improve algorithms, update cadence, batching, and resource management first.
- Benchmark a C# implementation if it provides a clear architectural or measured benefit.
- Introduce C++ GDExtension only for isolated, repeatable hotspots.

**Phase 4 — Reassess engine only with evidence**
- Compare Godot, Unity, or Unreal using the same representative gameplay workload and target hardware.
- Include migration cost, team familiarity, export requirements, tooling, and long-term maintenance—not raw microbenchmarks alone.

## 9. Official technical references

- Godot documentation: https://docs.godotengine.org/en/stable/
- Godot scripting languages: https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_languages.html
- Godot C#/.NET: https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/
- Godot GDExtension: https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/
- Godot performance: https://docs.godotengine.org/en/stable/tutorials/performance/
- Unity Burst: https://docs.unity3d.com/Packages/com.unity.burst@latest/
- Unity Job System: https://docs.unity3d.com/Manual/job-system.html
- Unity Entities/DOTS: https://docs.unity3d.com/Packages/com.unity.entities@latest/
- Microsoft C#: https://learn.microsoft.com/en-us/dotnet/csharp/
- Rust: https://www.rust-lang.org/learn

---

**Final engineering principle:** Choose the simplest language that meets the measured workload. For the current LATCHPOINT repository, Godot 4.7 is the baseline; GDScript is the default starting point, C# is an optional .NET path, and C++/GDExtension is a targeted optimization tool—not a blanket rewrite strategy.
