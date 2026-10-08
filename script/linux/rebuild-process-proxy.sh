#!/usr/bin/env bash
# Builds the process-proxy helper (used for Git hooks) for this machine from
# its source. process-proxy 0.6.0 ships an x86-64 binary named
# process-proxy-linux-arm64, and its install script keeps any binary that
# already exists, so arm64 builds would otherwise get the wrong one.

set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
arch="$(node -p process.arch)"

cd "$root/node_modules/process-proxy"
node "$root/node_modules/node-gyp/bin/node-gyp.js" rebuild --silent
cp "build/Release/process-proxy-linux-$arch" "bin/process-proxy-linux-$arch"
file "bin/process-proxy-linux-$arch"
