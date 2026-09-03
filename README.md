# clox

A hand-written implementation of **clox**, the bytecode virtual machine from
Robert Nystrom's *[Crafting Interpreters](https://craftinginterpreters.com/)*,
Part III (chapters 14-30).

Built in C23 with meson, in a Nix flake dev shell.

## Status

Not started. See [`docs/roadmap.md`](docs/roadmap.md) for the step list and the
working contract.

## Building

The dev shell provides clang, clang-tools, meson, ninja, pkg-config and
Criterion. With [direnv](https://direnv.net/) installed:

```sh
direnv allow          # first time only
```

Without direnv, prefix commands with `nix develop --command`.

```sh
meson setup build                                    # debug
meson setup build-asan -Db_sanitize=address,undefined
meson compile -C build
meson test -C build
meson test -C build-asan                             # the same tests, instrumented
./build/clox                                         # REPL (from ch16 onward)
./build/clox script.lox
```

Build settings: `c_std=c23`, `warning_level=3`, `werror=true` — that is
`-Wall -Wextra -Wpedantic -Werror`.

## Layout

```
src/          the interpreter; .c and .h side by side, as in the book
              everything but main.c is built into an internal static library
test/         Criterion unit tests, linked against that library
docs/         roadmap, divergences from the book, challenge log
```

`.clangd` points the language server at `build/`. Regenerating it is
unnecessary — meson keeps `build/compile_commands.json` current on every
reconfigure.

## This is not a transcription

The code here deliberately drifts from the book's. Each chapter is transcribed
faithfully first and then modernised to C23 in a separate commit, and structural
refactoring is pursued rather than avoided. Chapter challenges that earn their
keep are merged in.

[`docs/divergences.md`](docs/divergences.md) records every such difference and
what it costs in later chapters. [`docs/challenges.md`](docs/challenges.md)
records which challenges were adopted, which were rejected, and why.

## How the work is organised

One chapter at a time. Each step is filed as a GitHub issue carrying a spec —
goal, reasoning, files to write, verification commands, and one comprehension
question — then implemented, committed, and reviewed on that issue before the
next step begins. [`CLAUDE.md`](CLAUDE.md) describes the division of labour.

## Licence

MIT. See [LICENSE](LICENSE).
