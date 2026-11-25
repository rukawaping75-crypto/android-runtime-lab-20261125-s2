#!/usr/bin/env bash
set -euo pipefail

test -n "${TASK_ACQUIRE_B64:-}"

acquire_file="$(mktemp)"
cleanup() {
  set +e
  if [[ -f "$acquire_file" ]]; then
    shred -u "$acquire_file" 2>/dev/null || rm -f "$acquire_file"
  fi
  if [[ -f task-input.bin && ! -s task-input.bin ]]; then
    rm -f task-input.bin
  fi
}
trap cleanup EXIT

printf '%s' "$TASK_ACQUIRE_B64" | base64 --decode > "$acquire_file"
unset TASK_ACQUIRE_B64
chmod 0700 "$acquire_file"
bash "$acquire_file"
test -s task-input.bin

