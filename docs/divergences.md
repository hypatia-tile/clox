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

*No divergences yet — the first will arrive at the end of Step 1, when ch14 is
transcribed and then modernised.*
