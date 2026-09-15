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

### D-004 — an assertion utility, always live

| | |
| --- | --- |
| **Introduced** | Between Step 0 and ch14 |
| **The book** | No assertion facility. `common.h` carries `DEBUG_TRACE_EXECUTION` and friends; invariants are checked by reading. |
| **Here** | `src/check.h` provides `CHECK(cond, fmt, ...)` and `ABORT()`. Both write to `stderr` and call `abort()`, in **every** build. |
| **Why** | The interpreter's own bugs need to announce themselves at the point of violation rather than somewhere downstream. |
| **Blast radius** | Anywhere the book relies on a `default:` printing a diagnostic and continuing. ch14's `disassembleInstruction` is the first. |

**The line this depends on:** assertions catch the *programmer's* mistakes, never
the *user's*. A syntax error in a Lox source file is the user's and belongs to
the book's `runtimeError()`. A byte reaching a `switch` that cannot be an opcode
is the programmer's and belongs here. Blur this and the interpreter aborts on
bad input.

**Neither macro respects `NDEBUG`,** and this is deliberate. The obvious design
— compile the checks away in release — was rejected after measuring what C23's
`unreachable()` does when reached: at `-O2` the process died with `SIGSEGV`, but
at `-O0` it returned a null pointer, printed it, and **exited zero**. A function
that received an impossible value and reported success is worse than any
optimisation is worth. Behaviour identical across build types was chosen over a
branch of speed.

A trap worth remembering: `NDEBUG` has no automatic effect on a hand-written
macro. It is an ordinary name that only `<assert.h>` inspects. Honouring it
would have required writing `#ifdef NDEBUG`, which is deliberately not written.

**`CHECK` keeps `-Wformat` working.** The message is assembled by string-literal
concatenation, so the compiler still checks conversions against arguments
through the macro — `CHECK(1, "%d", "a string")` does not compile. Hand-rolled
assertion macros usually forfeit that. The variadic comma is handled by C23's
`__VA_OPT__(,)` rather than the GNU `, ##__VA_ARGS__` extension.

**`ABORT()` at the tail of a `switch` needs no `return` after it.** `abort()` is
`_Noreturn`, so `-Wreturn-type` stays quiet. And the switch carries **no
`default` label** on purpose: a default absorbs unhandled enumerators and
silences `-Wswitch`, which is the warning that will catch a forgotten opcode
somewhere among the forty that arrive before ch30.

### D-005 — counts and capacities are `clox_count_t`, a signed pointer-width type

| | |
| --- | --- |
| **Introduced** | Step 1 (ch14), `31b297b` |
| **The book** | `int count` and `int capacity` on every dynamic array. `common.h` exists to include `<stdbool.h>`, `<stddef.h>` and `<stdint.h>`. |
| **Here** | `common.h` declares `typedef ptrdiff_t clox_count_t` and `CLOX_COUNT_MAX` (`PTRDIFF_MAX`). `Chunk` uses it for `count` and `capacity`. |
| **Why** | `int` is 32 bits; `size_t` is wide enough but unsigned. `ptrdiff_t` is both wide and signed. |
| **Blast radius** | Every `printf` of a count or offset from ch14's disassembler onward: `%d` becomes `%td`. Every `int` count, capacity, offset or index the book declares on a growable structure — `ValueArray`, the VM stack, `Table`, the compiler's local and upvalue arrays. |

**Why not `size_t`.** Unsigned arithmetic wraps instead of going negative, so
`count - 1` at a count of zero is `SIZE_MAX`. Downward loops need contorted
termination conditions, and `-1` stops working as a sentinel — which the book
relies on from ch22, where a local's depth of `-1` means "declared but not yet
initialised". CPython reached the same conclusion and wrote it down: PEP 353's
`Py_ssize_t` is signed for these reasons.

**Why it gave `common.h` a job.** In C23 `bool`, `true` and `false` are keywords,
so the book's `common.h` was left with almost nothing to do. Owning the count
type is the reason it still exists.

**The cost is `%td`.** It is a cost with a safety net: `-Wformat` rejects `%d`
against a `ptrdiff_t`, so the book's format strings fail loudly rather than
printing garbage.

### D-006 — the growth policy is a `static inline` function that reports overflow

| | |
| --- | --- |
| **Introduced** | Step 1 (ch14), `26c587a`, reshaped in `31b297b` |
| **The book** | `#define GROW_CAPACITY(capacity) ((capacity) < 8 ? 8 : (capacity) * 2)`, used as `capacity = GROW_CAPACITY(oldCapacity)`. |
| **Here** | `static inline bool grow_capacity(clox_count_t *newCap, clox_count_t oldCap)` in `memory.h`. It writes the new capacity through the pointer and returns `true` if doubling overflowed, via `ckd_mul`. |
| **Why** | Nothing about the growth policy needs a macro, and a function can return the overflow verdict alongside the result. |
| **Blast radius** | Every chapter that grows an array: `ValueArray` (ch14), the VM stack if it is made growable, `Table` (ch20), and the GC's gray stack (ch26). Each `GROW_CAPACITY` call site becomes a call plus an overflow branch. |

**Which of the book's macros stay macros, and why.** A macro is needed when the
code must be generic over a type, or must see the caller's `__FILE__` and
`__LINE__`. `GROW_CAPACITY` is neither: it is arithmetic on one concrete type.
As a function it is type-checked where it is defined, visible to the debugger,
and cannot evaluate its argument twice. `GROW_ARRAY` and `FREE_ARRAY` take a
type as a parameter, which no function can, so they remain macros — for that
reason, not by habit.

**A macro's body is not checked until it is expanded.** A broken definition of
`GROW_ARRAY` sat in the tree compiling cleanly because nothing invoked it yet. A
function is checked where it is written. That is part of why the conversion was
worth making.

**`static`, not bare `inline`.** In a header, `static inline` gives each
translation unit its own copy. Bare `inline` promises an external definition
elsewhere and fails to link without one.

**The doubling is checked, although it cannot overflow in practice.** A capacity
past `PTRDIFF_MAX / 2` is not reachable by any Lox program. The check stayed
because a test *can* reach it — `test/test_memory.c` passes `CLOX_COUNT_MAX` —
and an overflow branch a test demonstrates is worth more than one argued away.
It costs one `ckd_mul` per growth.

**The return shape follows from checked arithmetic.** The result and the verdict
cannot both come back through one return value, so the result goes through a
pointer — the same shape `ckd_mul` itself has. The caller treats `true` as a
programmer's mistake: `writeChunk` calls `ABORT()` (D-008).

### D-007 — `reallocate` takes an element size and counts, and checks the multiplication

| | |
| --- | --- |
| **Introduced** | Step 1 (ch14), `26c587a`, reshaped in `31b297b` and `d98aa70` |
| **The book** | `void *reallocate(void *pointer, size_t oldSize, size_t newSize)`. `GROW_ARRAY` and `FREE_ARRAY` compute `sizeof(type) * count` themselves and pass byte sizes. |
| **Here** | `void *reallocate(size_t size, void *pointer, clox_count_t oldCount, clox_count_t newCount)`. The macros pass `sizeof(type)` and the counts; `reallocate` computes the byte size with `ckd_mul` and fails a `CHECK` if it overflows. |
| **Why** | The byte-size multiplication is the one place in the memory layer where overflow does real damage, and moving it into the function puts the check in exactly one place. |
| **Blast radius** | Every direct call to `reallocate` the book writes, starting with ch19's `ALLOCATE` and `allocateObject`. They pass byte sizes; here they pass an element size and a count — for a single object, `sizeof` the object and a count of `1`. `oldCount` is still unused, and is kept for a later chapter. |

**Why this multiplication and not others.** If `sizeof(type) * count` wraps, it
produces a *smaller* byte count. `realloc` succeeds, and every write that
follows runs off the end of the allocation: a corrupted heap with no diagnostic
anywhere. Plain multiplication cannot detect this. `ckd_mul`, from C23's
`<stdckdint.h>`, stores the product and returns whether it overflowed.

**Where the check lives changed while it was being written.** The plan in #10
was to guard the multiplication inside `GROW_ARRAY`. It landed in `reallocate`
instead: the macros shrink to passing arguments, and every caller — including
ones added in ch19 that bypass `GROW_ARRAY` — is checked without needing to
remember to be.

**Why `oldCount` survives unused.** The book's `oldSize` is unused in ch14 too,
and is there for a later chapter's benefit. Here it becomes a count, and the
byte size it stands for is `oldCount * size`. That product needs no check, as
long as callers pass the count they allocated with: it is then no larger than a
`newCount * size` that already passed one. What the later
chapter wants from it is the subject of #8's comprehension question, and is
deliberately not written here until that question is answered.

**C23's `[[maybe_unused]]`** marks `oldCount`, in place of the traditional
`(void)oldCount;` statement. It states the intent in the signature rather than
in the body.

### D-008 — three kinds of failure, three ways out

| | |
| --- | --- |
| **Introduced** | Step 1 (ch14), alongside D-007 |
| **The book** | Allocation failure calls `exit(1)`. Compile and runtime errors in Lox code go through `errorAt` (ch17) and `runtimeError` (ch18). The book has no assertion facility and does not separate the interpreter's own bugs from these. |
| **Here** | Every failure is classified before it is handled, by whose fault it is. |
| **Why** | Each kind needs a different exit, and blurring them either hides the interpreter's bugs or aborts on bad input. |
| **Blast radius** | ch17 and ch18, where the user-error path arrives and the line has to be held. ch26, where allocation failure becomes interesting. Any `default:` or impossible branch the book writes. |

| Kind | Example | Handling |
| --- | --- | --- |
| **Programmer's mistake** | a byte that cannot be an opcode; a size computation that overflowed | `CHECK` / `ABORT()` → `abort()` |
| **User's mistake** | a syntax error in a Lox file; adding a string to a number | the book's `errorAt` / `runtimeError` |
| **Environment failure** | out of memory | `exit()` |

**Overflow is a programmer's mistake, not an out-of-memory.** A request for more
than `SIZE_MAX` bytes is not "input too large": it is evidence that a count
computation is broken. Sending it down the out-of-memory path would report a
bug as an environmental accident. `CHECK` reports the location and the values;
the out-of-memory path currently reports nothing.

**Out of memory is neither of the other two.** It is not a bug, so `abort()`
overstates it, and it is not the user's fault, so there is nothing to report
back to them or recover to. `exit()` is also the better primitive for a
concrete reason: it runs `atexit` handlers and flushes stdio, so output produced
before the failure is not lost. `abort()` does neither.

Today `reallocate` exits silently on out-of-memory. Saying *which* allocation
failed, and how large it was, is #9 — deferred until ch26 or until the silence
costs time.
