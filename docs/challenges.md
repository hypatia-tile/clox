# Challenges

*Crafting Interpreters* ends each chapter with challenges. This file records
what was attempted, what was adopted, and — just as importantly — what was
rejected and why.

## How challenges are run

Each attempt lives on a `challenge/chNN-<slug>` branch cut from `main`.

- **Adopted** — merged into `main`. It gets an entry here *and* an entry in
  `docs/divergences.md`, because from that point the book's code no longer
  describes this repository.
- **Rejected** — the branch is left unmerged (or deleted) and an entry is written
  here anyway. A rejected challenge with a stated reason is worth as much as an
  adopted one: it records a design decision that was considered, not one that
  was never seen.
- **Skipped** — noted in one line. No branch.

## How to read an entry

| Field | Meaning |
| --- | --- |
| **Challenge** | The chapter and the challenge's question, in one sentence |
| **Verdict** | Adopted / Rejected / Skipped |
| **What was built** | The approach taken, and the branch |
| **Why this verdict** | The reasoning — the part worth re-reading later |
| **Cost** | For adopted ones: what it makes harder in later chapters |

## Log

*Nothing attempted yet. The first challenges arrive with ch14 (Step 1) — the
run-length encoded line information and the `OP_CONSTANT_LONG` instruction are
the two that most affect what comes after.*
