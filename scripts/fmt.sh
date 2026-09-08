#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

files=(src/*.c src/*.h test/*.c test/*.h)

if [ ${#files[@]} -eq 0 ]; then
  echo "ok: no source to format"
  exit 0
fi

clang-format -i "${files[@]}" 2>&1
