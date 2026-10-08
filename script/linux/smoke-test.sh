#!/usr/bin/env bash
# Starts a packaged GitHub Desktop under a virtual X display and checks that
# the renderer got through startup and the app is still running afterwards.
#
# Usage: smoke-test.sh <path-to-executable> [extra app arguments...]

set -euo pipefail

app="$1"
shift

profile="$(mktemp -d)"
out="$profile/stdout.log"

setsid xvfb-run -a "$app" --user-data-dir="$profile" "$@" >"$out" 2>&1 &
pid=$!

started=false
for _ in $(seq 1 90); do
  if grep -qs 'launching: ' "$profile"/logs/*.log; then
    started=true
    break
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    break
  fi
  sleep 1
done

# Give a crash right after startup a chance to show up.
sleep 10
alive=false
if kill -0 "$pid" 2>/dev/null; then
  alive=true
fi

kill -- "-$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

if [[ "$started" == true && "$alive" == true ]]; then
  grep -h 'launching: ' "$profile"/logs/*.log
  echo "Smoke test passed"
  exit 0
fi

echo "Smoke test failed (started=$started, alive=$alive)"
echo "--- stdout/stderr"
tail -n 100 "$out" || true
echo "--- app log"
tail -n 100 "$profile"/logs/*.log 2>/dev/null || true
exit 1
