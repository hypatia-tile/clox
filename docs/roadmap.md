# Roadmap

Building **clox**, the bytecode virtual machine from *Crafting Interpreters*
Part III, by hand — chapters 14 through 30.

## Working Contract

*(This is the 進め方の契約 section that `step-start` and `step-review` look for.)*

**The owner writes all code.** `flake.nix`, `meson.build`, `src/`, `test/` —
every line. Claude never writes code, not even a snippet or a "roughly like
this". Naming a function or a struct field is specification; writing its body is
implementation, and implementation belongs to the owner.

**Claude writes documentation and runs git.** `docs/`, `README.md`, `CLAUDE.md`,
issue specs, review comments, **and commit messages** — Claude also executes
`git commit` and `git push`, so the owner never has to stop and phrase a commit.

**One step at a time.**

1. `step-start` files the next unchecked step below as a GitHub issue with a full
   spec: goal, reasoning, files to write, verification commands, one
   comprehension question with the answer withheld.
2. The owner implements, verifies, and says it is done.
3. Claude commits along the book's section boundaries and pushes.
4. `step-review` pins to those hashes, reads what was actually written, and
   comments on the issue: **Must fix** / **Your call** / **Minor**.
5. Once no Must-fix remains, Claude closes the issue and ticks the box here.

**Do not start a step while the previous issue is open.** Fixes go in new
commits — never amend, because amending orphans the hash a review points at.

**Everything in this repository and on GitHub is English.** Chat is Japanese.

### How this implementation relates to the book

The code here **deliberately drifts from the book's**, in two ways:

- **C23 modernisation.** Each chapter is transcribed faithfully first — build it
  the book's way, make it work — then modernised in a separate commit at the end
  of the step. Keeping these apart means a bug is always attributable: either the
  transcription or the modernisation, never ambiguously both.
- **Structural refactoring, pursued actively.** Where the book's structure is
  shaped by pedagogy rather than by what the code wants, it gets changed.

Every drift is recorded in `docs/divergences.md`. Adopted challenges are
recorded in `docs/challenges.md`.

The consequence: **the book's code snippets will stop applying verbatim.**
Translating them is Claude's job — every spec reads the current source and says
"the book writes X; in your code that is Y." Claude must read
`docs/divergences.md` before writing any spec.

### Challenges

Attempted on a `challenge/chNN-<slug>` branch. If the owner likes the result it
merges into `main` and gets an entry in both `docs/challenges.md` and
`docs/divergences.md`. If not, the branch is left unmerged or deleted, and
`docs/challenges.md` records why it was rejected — a rejected challenge with a
stated reason is worth as much as an adopted one.

### Build

C23, clang only, meson + ninja, warnings at `warning_level=3` with `werror`.
Two build directories: `build/` (debug) and `build-ubsan/`
(`b_sanitize=undefined`). Tests use Criterion. AddressSanitizer is unavailable
locally — see `docs/divergences.md`. See `CLAUDE.md`.

## Steps

Heavy chapters are split into two or three steps. **The split is decided
immediately before entering that chapter**, not now — how far the code has
drifted by then determines where the seams fall. Chapters marked *(split
expected)* are the candidates.

- [ ] **Step 0 — Environment** *(issues #3, #4; originally #1, superseded)*
      Nix flake dev shell, meson build, `build/` + `build-ubsan/`, Criterion
      wired up, clangd healthy. `src/main.c` prints `hello, clox` and nothing
      more. Goal: never fight the toolchain again after this.

      Two things grew out of this step without being conditions of it: an
      assertion utility (#5) and housekeeping (#6).

### Getting to a running interpreter

- [ ] **Step 1 — ch14 Chunks of Bytecode**
      A `Chunk` of bytecode with a growable array behind it, a constant pool,
      line information, and a disassembler to read it back.
- [ ] **Step 2 — ch15 A Virtual Machine**
      The execution loop, a value stack, and arithmetic. The first time the
      bytecode actually runs.
- [ ] **Step 3 — ch16 Scanning on Demand**
      A scanner that hands out tokens one at a time rather than building a list.
- [ ] **Step 4 — ch17 Compiling Expressions**
      Pratt parsing straight to bytecode. **`lox` becomes a real program here**
      — this is also where `packages.default` and CI get added. CI is where
      AddressSanitizer finally runs, on Linux; it cannot run locally.

### A language with values

- [ ] **Step 5 — ch18 Types of Values**
      A tagged union for `Value`; booleans, `nil`, and the comparison operators.
- [ ] **Step 6 — ch19 Strings**
      Heap-allocated objects, the `Obj` header, and string concatenation.
      First real memory management.
- [ ] **Step 7 — ch20 Hash Tables**
      An open-addressing hash table, and string interning on top of it.

### Statements, state, and control flow

- [ ] **Step 8 — ch21 Global Variables**
      Statements, the global variable table, and the compiler's error recovery.
- [ ] **Step 9 — ch22 Local Variables**
      Locals resolved to stack slots at compile time — no hash lookup at runtime.
- [ ] **Step 10 — ch23 Jumping Back and Forth**
      Conditional and looping control flow via jump instructions and backpatching.

### Functions and closures

- [ ] **Step 11 — ch24 Calls and Functions** *(split expected)*
      Function objects, call frames, native functions. The VM's shape changes
      substantially here.
- [ ] **Step 12 — ch25 Closures** *(split expected)*
      Upvalues, and closing over variables that have left the stack.

### Memory

- [ ] **Step 13 — ch26 Garbage Collection** *(split expected)*
      A mark-sweep collector: roots, tracing, the tricolour invariant, and
      finding out which of the earlier chapters had latent bugs.

### Objects

- [ ] **Step 14 — ch27 Classes and Instances**
      Classes, instances, and fields.
- [ ] **Step 15 — ch28 Methods and Initializers** *(split expected)*
      Methods, `this`, initialisers, and the optimised invocation path.
- [ ] **Step 16 — ch29 Superclasses**
      Inheritance and `super`.

### Making it fast

- [ ] **Step 17 — ch30 Optimization**
      NaN boxing and a faster hash table — measured, not assumed.

## Progress

Nothing started yet.
