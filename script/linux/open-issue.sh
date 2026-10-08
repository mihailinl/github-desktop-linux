#!/usr/bin/env bash
# Opens an issue labelled upstream-sync unless an open one with the same title
# already exists, so a scheduled run does not report the same problem twice.
#
# Usage: open-issue.sh <title> <body-file>

set -euo pipefail

title="$1"
body_file="$2"

gh label create upstream-sync --color FBCA04 \
  --description 'A new upstream release needs attention' --force >/dev/null

existing="$(gh issue list --label upstream-sync --state open --limit 100 \
  --json number,title --jq ".[] | select(.title == \"$title\") | .number")"

if [[ -n "$existing" ]]; then
  echo "Issue #$existing is already open: $title"
else
  gh issue create --title "$title" --label upstream-sync --body-file "$body_file"
fi
