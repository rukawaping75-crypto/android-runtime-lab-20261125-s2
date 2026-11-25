#!/usr/bin/env bash
set -euo pipefail

test -n "${TASK_PAYLOAD_B64:-}"
test -f evidence-recipient.pem
openssl x509 -in evidence-recipient.pem -noout >/dev/null

payload_file=""
archive_file=""
cipher_ready=0

cleanup_plaintext() {
  set +e
  if [[ -n "$payload_file" && -f "$payload_file" ]]; then
    shred -u "$payload_file" 2>/dev/null || rm -f "$payload_file"
  fi
  if [[ -n "$archive_file" && -f "$archive_file" ]]; then
    shred -u "$archive_file" 2>/dev/null || rm -f "$archive_file"
  fi
  if [[ -d evidence ]]; then
    find evidence -type f -exec shred -u {} + 2>/dev/null || find evidence -type f -delete
    rmdir evidence 2>/dev/null || true
  fi
  if [[ "$cipher_ready" != "1" && -f encrypted-evidence.der ]]; then
    shred -u encrypted-evidence.der 2>/dev/null || rm -f encrypted-evidence.der
  fi
}
trap cleanup_plaintext EXIT

mkdir -p evidence
payload_file="$(mktemp)"
archive_file="$(mktemp)"
printf '%s' "$TASK_PAYLOAD_B64" | base64 --decode > "$payload_file"
unset TASK_PAYLOAD_B64
chmod 0700 "$payload_file"

set +e
bash "$payload_file" > evidence/payload.log 2>&1
payload_rc=$?
set -e
printf 'PAYLOAD_EXIT_CODE=%s\n' "$payload_rc" > evidence/runner-status.txt

tar -czf "$archive_file" -C evidence .
openssl cms -encrypt -binary -aes-256-cbc -outform DER \
  -in "$archive_file" -out encrypted-evidence.der evidence-recipient.pem
cipher_ready=1

echo "ENCRYPTED_ANDROID_PAYLOAD_FINISHED rc=$payload_rc"
exit "$payload_rc"

