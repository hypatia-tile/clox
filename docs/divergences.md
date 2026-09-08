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

### D-002 — `OpCode` lives in its own translation unit

| | |
| --- | --- |
| **Introduced** | Step 0 |
| **The book** | `OpCode` is declared in `chunk.h`, and `disassembleInstruction` prints each mnemonic from inside its own `switch`. There is no separate opcode file and no function that maps an opcode to its name. |
| **Here** | `src/opcode.{c,h}` holds the enum and `opcodeName`, a pure function returning the mnemonic. |
| **Why** | Two reasons, one structural and one incidental. |
| **Blast radius** | ch14's disassembler, which will call `opcodeName` instead of printing inline. Every later chapter that adds an opcode touches `opcode.c` rather than `chunk.h`. |

The structural reason: the book's mnemonic lookup is not really part of
disassembly, it is a fact about opcodes that disassembly happens to be the
first caller of. Extracted, it becomes a total function from opcode to string —
something that can be tested directly, which the `switch` inside a printing
routine cannot be without capturing stdout.

The incidental reason is worth recording because it shaped the choice: at Step 0
the static library had no sources at all, `main.c` being the only file. meson
accepts a library with no sources but warns that it works by accident and will
stop being allowed. Something real had to go in, and inventing a version string
would have been scaffolding thrown away by ch14. An opcode table is the first
thing ch14 needs anyway.

The contract for values that are not opcodes is **not yet decided** — see #7.

### D-003 — `-Wwrite-strings` is enabled project-wide

| | |
| --- | --- |
| **Introduced** | Step 0 |
| **The book** | Written against a C99-era dialect with ordinary warnings. String literals are assigned to `char *` where convenient. |
| **Here** | `add_project_arguments('-Wwrite-strings', …)`, so string literals type as `const char[N]` and assigning one to `char *` is an error under `werror`. |
| **Why** | The type system otherwise declines to defend what the standard forbids. |
| **Blast radius** | **Expect the book's code to stop compiling at intervals.** The disassembler in ch14, the token strings in ch16, the string object in ch19, and the error messages from ch21 onward are the likely places. |

In C a string literal has type `char[N]`, not `const char[N]`, so
`char *p = "literal";` is well typed and no diagnostic is owed — yet writing
through `p` is undefined behaviour. `const` arrived in C89, by which time too
much code already did this for the type to be changed; the committee left the
type alone and made modification undefined instead. C++, having no such legacy,
types literals `const` and rejects the line outright.

`-Wwrite-strings` restores that missing `const`. This is why the diagnostic it
produces is `-Wincompatible-pointer-types-discards-qualifiers` and never names
the flag: nothing new is being detected, the operand merely stopped
misrepresenting itself.

**When the book's code fails to compile under this, that is the divergence
working, not a transcription error.** The fix is nearly always to add `const`
to the receiving type. Record anything more interesting than that here.

One caveat for later: `add_project_arguments` applies to every target in the
project. An earlier attempt used per-target `c_args` and missed the static
library entirely — silently, since a flag that never arrives produces no
diagnostic. If sanitizer or dependency-specific builds are added later and
something needs exempting, exempt it explicitly rather than reverting to
per-target flags.
