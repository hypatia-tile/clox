# Divergences from the book

Where this implementation deliberately differs from *Crafting Interpreters*, and
what that means for reading the book's later chapters.

**Read this before writing any spec.** The book's snippets are quoted against
*its* codebase; from the first entry below onward they stop applying verbatim to
this one. Translating them is the spec's job.

## Why this file exists

Two decisions guarantee drift:

1. Each chapter is transcribed faithfully, then **modernised to C23** in a
   separate commit.
2. **Structural refactoring is pursued actively**, not merely tolerated.

Drift is cheap to create and expensive to remember. This ledger is the memory.

## How to read an entry

| Field | Meaning |
| --- | --- |
| **Introduced** | The step and commit where the divergence entered |
| **The book** | What *Crafting Interpreters* does |
| **Here** | What this repository does instead |
| **Why** | The reasoning. The most valuable field |
| **Blast radius** | Which later chapters will quote code that no longer applies |

An entry is only worth writing if **Blast radius** is filled in honestly. An
entry that claims a change affects nothing is usually an entry written too
early.

## Ledger

### D-001 — AddressSanitizer is not used locally

| | |
| --- | --- |
| **Introduced** | Step 0 |
| **The plan** | Two build directories, `build/` and `build-asan/`, the latter at `b_sanitize=address,undefined`, with the test suite passing in both. Chosen for chapter 26, where a garbage collector is debugged. |
| **Here** | `build/` and `build-ubsan/` at `b_sanitize=undefined`. AddressSanitizer runs on Linux in CI from Step 4 and not at all on this machine. |
| **Why** | It does not work here. Any binary built with `-fsanitize=address` on this toolchain hangs before reaching `main`. |
| **Blast radius** | Chapter 26 above all — a use-after-free found by CI reports against a Linux run rather than a local one. Chapters 19, 20 and 25 to a lesser degree. |

This is a divergence from the plan agreed at the start of the project, not from
the book. It is recorded here because the reasoning is worth keeping.

**The mechanism.** ASan's initialiser installs a malloc interceptor. During
init, `__sanitizer::get_dyld_hdr()` allocates; that allocation is routed back
into `AsanInitFromRtl()`, which is already holding the init lock; the re-entrant
call spins on `StaticSpinMutex::LockSlow()` forever. The process never reaches
`main`.

**What was ruled out.** The obvious hypothesis was that nixpkgs' ASan runtime is
built against the macOS 14.4 SDK while the host runs 26.5.2 — Apple's own
runtime reports `sdk 26.4` and works. That hypothesis was tested by rebuilding
compiler-rt against `apple-sdk_26`: the override took effect (`sdk 26.5`), and
the rebuilt runtime **deadlocked in exactly the same place**. The SDK version
was correlated, not causal. Do not retry this.

The difference is in the source: Apple patches the sanitizer runtimes they ship,
and upstream LLVM 21.1.8 — which is what nixpkgs ships — has this bug on macOS
26. Also ruled out: it is unrelated to Criterion (a bare `printf` binary hangs
identically), and unrelated to linking or symbols (both runtimes import the same
malloc symbols from libSystem).

**Why UBSan and not nothing.** UBSan installs no malloc interceptors, never
enters the broken path, and is verified working here. It catches a genuinely
different class of bug than ASan, so keeping it is not a consolation prize —
but it will not catch the use-after-free that chapter 26 produces.

**The escape hatch.** Apple's toolchain has a working runtime.
`xcrun clang -fsanitize=address` on a single file is available ad hoc without
`meson.build` knowing anything about it. This is deliberately not wired into the
build, so that no build directory depends on the host toolchain.

**When to revisit.** At any nixpkgs bump: build anything with
`-fsanitize=address` and run it. If it completes, upstream has fixed
`get_dyld_hdr()` and this entry can be retired.

Full investigation: issue #2.
