#!/usr/bin/env bash
# Is clangd actually reading our compilation database?
#
# `clangd --check` prints "All checks completed, 0 errors" even when it failed
# to find the database entirely -- it falls back to default flags, under which
# a simple file parses fine. The only proof is the load line, so that is what
# this looks for.
set -euo pipefail

status=0
for f in src/*.c; do
  out=$(clangd --check="$f" 2>&1 || true)

  if ! grep -q 'Loaded compilation database' <<<"$out"; then
    echo "FAIL: $f -- no compilation database loaded"
    grep -E "Unknown Config key|Failed to find compilation database" <<<"$out" | sed 's/^/       /'
    status=1
    continue
  fi
  if ! grep -q 'All checks completed, 0 errors' <<<"$out"; then
    echo "FAIL: $f -- diagnostics reported"
    grep -E '^(E|error)' <<<"$out" | head -5 | sed 's/^/       /'
    status=1
    continue
  fi
  echo "ok: $f"
done
exit $status
