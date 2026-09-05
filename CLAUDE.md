# CLAUDE.md

Working agreement for this repository. Read this before doing anything here.

## What this repository is

A hand-written implementation of **clox**, the bytecode virtual machine from
Robert Nystrom's *Crafting Interpreters*, Part III (chapters 14-30).

This is a **learning project**. The goal is not to produce clox as fast as
possible — it is for the repository owner to understand every line by writing
it. Optimising for delivery speed at the cost of that understanding defeats the
purpose.

## Division of labour

| Who | What |
| --- | --- |
| **The owner** | All code. `flake.nix`, `meson.build`, `src/`, `test/`, `.clang-format`, `scripts/` — everything that is not documentation, with one exception below. |
| **Claude** | `docs/`, `README.md`, this file, **`scripts/agents/`**, GitHub issue specs, reviews, **and commit messages**. Claude also *executes* `git commit` and `git push`. |

### `scripts/` and `scripts/agents/`

`scripts/` belongs to the owner; Claude reviews it like any other code and never
edits it.

`scripts/agents/` belongs to Claude: the checks it runs over and over. The owner
reviews these and weighs in, but does not maintain them.

The line between them is **what the output is for**:

- **`scripts/agents/`** is read by a machine. Terse output, and an exit code that
  means something — Claude acts on pass/fail.
- **`scripts/`** is read by a person. Legible output matters; the exit code is
  secondary.

One rule for both, learned the hard way when a script named `fmt_check.sh` ran
`clang-format -i` and silently rewrote the tree: **a check never modifies
files.** If it can edit, its name says so.

**Claude never writes code.** Not a snippet, not a "here's roughly what it looks
like", not a fix applied to the working tree. Naming a function, a struct field,
or a flag is specification; writing its body or its value is implementation, and
implementation belongs to the owner.

The one exception: Claude writes and commits the files listed in its row above.

Claude runs `git commit` and `git push` on the owner's behalf so the owner never
has to think about commit messages. Claude reads the diff, splits it along the
book's section boundaries, and writes the messages.

## Workflow

One step at a time, driven by two skills:

1. `step-start` — picks the first unchecked step in `docs/roadmap.md`, files it
   as a GitHub issue with a full spec, and stops. The owner implements.
2. `step-review` — pins to the committed hashes, reads what was actually
   written, and records findings as a comment on that issue.

Each issue spec ends with **one comprehension question whose answer is
withheld**. The owner finds out and reports back.

When the owner is stuck, give a graded hint first. Give the answer only if the
hint fails.

`step-start` and `step-review` refer to a section called 進め方の契約 (working
contract). In this repository that section is **`docs/roadmap.md` § Working
Contract**.

### Issues are kept readable, by superseding

An issue must be workable by reading its body alone. Once corrections in the
comments contradict the body, it has stopped being instructions and become an
archive.

When intent changes that far, **supersede rather than edit**: agree the split
with the owner first, open the replacement issues, then close the original with
a comment naming them and stating what was achieved under it. Editing the body
in place would erase what was originally believed, which is often the most
useful thing on the page.

A step may therefore span several issues. `docs/roadmap.md` names which ones
close it.

One issue, one concern. Environment setup, a code-review finding, and a new
design all belong in separate issues even when they surfaced in the same hour.

## Language

**Everything committed to this repository, and everything posted to GitHub, is
in English** — docs, README, issue specs, review comments, commit messages, code
comments.

Chat with the owner is in Japanese.

`step-review` sorts findings into three tiers. In this repository they are named:

- **Must fix** — real harm; it breaks a later chapter or causes an incident
- **Your call** — not wrong, but the owner should be able to say why they chose it
- **Minor** — taste; explicitly does not need fixing

## Build

```sh
direnv allow                 # first time only; generates flake.lock
meson setup build            # debug
meson setup build-ubsan -Db_sanitize=undefined
meson compile -C build
meson test -C build
meson test -C build-ubsan
```

AddressSanitizer is **not** used locally. Its runtime deadlocks at init on this
macOS — see `docs/divergences.md`. ASan runs on Linux in CI from Step 4.

- C standard: **C23** (`c_std=c23`)
- Warnings: `warning_level=3` + `werror=true` (`-Wall -Wextra -Wpedantic -Werror`)
- Compiler: clang only, from the flake's dev shell
- Layout: `src/` is flat — `.c` and `.h` live side by side, as in the book's
  `c/` directory. Everything except `main.c` is built into an internal static
  library so both the `clox` executable and the tests can link it.
- Tests: **Criterion**, via `dependency('criterion')`
- clangd reads `build/` — see `.clangd`. Never point it at `build-ubsan/`; the
  sanitizer flags skew the diagnostics.

## How the book is followed

Read `docs/roadmap.md` for the step list and the working contract, and
`docs/divergences.md` before writing any spec — **the code in this repository
deliberately drifts from the book's**, and a spec that quotes the book verbatim
will not apply.

Two kinds of deliberate drift:

- **C23 modernisation** — each chapter is transcribed faithfully first, then
  modernised in a separate commit at the end of the step
- **Structural refactoring** — pursued actively, not just tolerated

Both are recorded in `docs/divergences.md`. Challenges the owner adopted are
recorded in `docs/challenges.md`.

When writing a spec, Claude's job is to **translate**: "the book writes X; in
your current code that is Y." Never paste the book's code and never assume the
owner's code still matches it — read the files.

## Commits and branches

- Main-line transcription goes **straight to `main`**. No PRs.
- One commit per section of the book, plus a final C23-modernisation commit for
  the step.
- Challenges are attempted on `challenge/chNN-<slug>`. If the owner likes the
  result it is merged into `main`; otherwise the branch is left or deleted.
- **Never amend.** Fixes go in new commits — amending orphans the hash a review
  comment points at.
