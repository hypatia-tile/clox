#!/usr/bin/env zsh

set -euo pipefail

meson setup build --wipe
meson setup build-ubsan -Db_sanitize=undefined --wipe

meson compile -C build
meson compile -C build-ubsan

