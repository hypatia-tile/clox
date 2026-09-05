#!/usr/bin/env bash
# Run a command under a hard time cap, reporting a hang as a hang.
#
# Written after AddressSanitizer binaries deadlocked at init (#2) and left
# processes spinning on sched_yield for fifteen hours, heating the machine.
# Anything that might hang goes through here.
#
#   scripts/agents/run-capped.sh 10 ./build/clox_test
set -uo pipefail

cap="${1:?usage: run-capped.sh SECONDS COMMAND [ARGS...]}"
shift

"$@" & pid=$!
( sleep "$cap"; kill -9 "$pid" 2>/dev/null ) & killer=$!

wait "$pid" 2>/dev/null; rc=$?
kill "$killer" 2>/dev/null || true
wait "$killer" 2>/dev/null || true

case $rc in
  137|9) echo "HUNG: killed after ${cap}s -- $*"; exit 124 ;;
  0)     exit 0 ;;
  *)     echo "exit=$rc -- $*"; exit "$rc" ;;
esac
