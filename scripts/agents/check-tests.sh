#!/usr/bin/env bash
# Do the tests actually test anything?
#
# `meson test` reports Ok for a binary that runs and exits 0, which a test
# executable does even when Criterion never registered a single test -- as
# happened here from c8dabf2 until #4, when clox_test was built from
# src/main.c and its main() won over Criterion's. This checks for Criterion's
# own synthesis line and for a non-zero test count.
set -euo pipefail

builddir="${1:-build}"

meson test -C "$builddir" >/dev/null

synthesis=$("$builddir/clox_test" 2>&1 | grep -F '[====] Synthesis:' || true)
if [ -z "$synthesis" ]; then
  echo "FAIL: no Criterion synthesis line -- the test binary is not running Criterion"
  exit 1
fi

tested=$(sed -n 's/.*Tested: \([0-9]*\).*/\1/p' <<<"$synthesis")
failing=$(sed -n 's/.*Failing: \([0-9]*\).*/\1/p' <<<"$synthesis")
crashing=$(sed -n 's/.*Crashing: \([0-9]*\).*/\1/p' <<<"$synthesis")

if [ "${tested:-0}" -eq 0 ]; then
  echo "FAIL: Criterion ran but registered 0 tests"
  exit 1
fi
if [ "${failing:-0}" -ne 0 ] || [ "${crashing:-0}" -ne 0 ]; then
  echo "FAIL: $synthesis"
  exit 1
fi

echo "ok: $builddir -- tested $tested, all passing"
