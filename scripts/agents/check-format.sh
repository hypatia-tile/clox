#!/usr/bin/env bash
# Is the tree formatted? Reports only; never edits.
#
# Covers test/ as well as src/ -- the owner's scripts/fmt*.sh look only at
# src/*.{c,h}, which is why test/test_opcode.c stayed unformatted.
set -euo pipefail

files=$(ls src/*.c src/*.h test/*.c 2>/dev/null || true)
[ -z "$files" ] && { echo "ok: nothing to format"; exit 0; }

# shellcheck disable=SC2086
if out=$(clang-format --dry-run --Werror $files 2>&1); then
  echo "ok: $(wc -w <<<"$files" | tr -d ' ') files formatted"
else
  echo "FAIL: formatting violations"
  grep 'error:' <<<"$out" | sed 's/^/       /'
  exit 1
fi
