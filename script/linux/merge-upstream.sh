#!/usr/bin/env bash
# Merges an upstream GitHub Desktop release tag (e.g. release-3.6.7) into the
# current branch and settles the conflicts that come back on every release:
# package.json files are merged key by key, the app version becomes
# <upstream version>-linux1, and the lockfiles are rebuilt when needed.
#
# Usage: merge-upstream.sh <upstream-tag>
# Exit codes: 0 merged and committed (or nothing to do); 2 conflicts are left
# in the working tree for a person or an agent to resolve.

set -euo pipefail

tag="$1"
version="${tag#release-}-linux1"
here="$(dirname "$0")"

if git merge-base --is-ancestor "$tag" HEAD; then
  echo "$tag is already merged"
  exit 0
fi

base="$(git merge-base HEAD "$tag")"

git merge --no-ff --no-commit "$tag" || true
if ! git rev-parse -q --verify MERGE_HEAD >/dev/null; then
  echo "git merge of $tag did not start"
  exit 1
fi

for file in package.json app/package.json; do
  args=("$base" "$tag" "$file")
  if [[ "$file" == app/package.json ]]; then
    args+=("$version")
  fi
  if node "$here/merge-package-json.mjs" "${args[@]}"; then
    git add "$file"
  fi
done

# The app's dependencies are the same as upstream's, so its lockfile is too.
if git diff --name-only --diff-filter=U | grep -qx 'app/yarn.lock'; then
  git show "$tag:app/yarn.lock" >app/yarn.lock
  git add app/yarn.lock
fi

# The root lockfile is upstream's plus the Linux packaging tools. If the text
# merge left it conflicted or stale, rebuild it from upstream's lockfile.
# --ignore-scripts keeps package install scripts from running here.
if ! git diff --name-only --diff-filter=U | grep -qx 'package.json' &&
  { git diff --name-only --diff-filter=U | grep -qx 'yarn.lock' ||
    ! yarn install --frozen-lockfile --ignore-scripts --non-interactive >/dev/null; }; then
  echo "Rebuilding yarn.lock from $tag"
  git show "$tag:yarn.lock" >yarn.lock
  yarn install --ignore-scripts --non-interactive >/dev/null
  git add yarn.lock
fi

conflicts="$(git diff --name-only --diff-filter=U)"
if [[ -n "$conflicts" ]]; then
  echo "Unresolved conflicts after merging $tag:"
  echo "$conflicts"
  exit 2
fi

git commit --no-edit -m "Merge upstream $tag ($version)"
echo "Merged $tag as $version"
