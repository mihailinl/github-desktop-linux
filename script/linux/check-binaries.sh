#!/usr/bin/env bash
# Usage: script/linux/check-binaries.sh <app-dir> <x64|arm64>
#
# Removes the Copilot helper binaries for the other Linux architecture (the
# arm64 Copilot package ships both), then fails if any ELF file in the
# packaged app is built for a different architecture than the package.

set -euo pipefail

app="$1"
arch="$2"

case "$arch" in
  x64) other=arm64 elf='x86-64' ;;
  arm64) other=x64 elf='ARM aarch64' ;;
  *)
    echo "Unknown architecture '$arch'" >&2
    exit 1
    ;;
esac

if [[ -d "$app/resources/app/copilot" ]]; then
  find "$app/resources/app/copilot" -type d -path "*/bin/linux-$other" -prune \
    -print -exec rm -rf {} +
fi

wrong="$(find "$app" -type f -print0 | xargs -0 file -N -F '|' |
  grep '| *ELF' | grep -v "$elf" || true)"
if [[ -n "$wrong" ]]; then
  echo "Binaries for the wrong architecture in $app (expected $elf):" >&2
  echo "$wrong" >&2
  exit 1
fi
echo "All binaries in $app are $elf"
