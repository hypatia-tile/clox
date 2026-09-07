#!/usr/bin/env bash
# Is the tree formatted? Reports only; never edits.
#
# nullglob makes an unmatched pattern vanish rather than being passed through
# as a literal filename -- test/ has no headers yet, and without this
# `clang-format test/*.h` would fail trying to open a file called "test/*.h".
# The empty guard then covers the case where nothing matches at all, since
# clang-format with no arguments reads stdin and hangs.
set -euo pipefail
shopt -s nullglob

files=(src/*.c src/*.h test/*.c test/*.h)

if [ ${#files[@]} -eq 0 ]; then
  echo "ok: no sources to format"
  exit 0
fi

if out=$(clang-format --dry-run --Werror "${files[@]}" 2>&1); then
  echo "ok: ${#files[@]} files formatted"
else
  echo "FAIL: formatting violations"
  grep 'error:' <<<"$out" | sed 's/^/       /'
  exit 1
fi
