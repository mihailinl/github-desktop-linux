# Maintaining the Linux builds

The `linux` branch is upstream `desktop/desktop` plus the Linux support. Upstream
release tags (`release-X.Y.Z`) are merged into it, never rebased, so every
upstream commit stays reachable and later merges only see new changes.

## Workflows

| Workflow                                                            | What it does                                                                                                                                                        |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Linux CI](../../.github/workflows/linux-ci.yml)                    | Builds x64 and arm64, runs unit tests, packages AppImage, deb, rpm and tar.gz, starts the packaged app under Xvfb, and runs the end-to-end launch test.                |
| [Linux release](../../.github/workflows/linux-release.yml)          | When the version in `app/package.json` has no release yet: builds with Linux CI, tests the Arch package in an Arch container, attests every file and creates the release. |
| [Upstream sync](../../.github/workflows/linux-upstream-sync.yml)    | Every 6 hours: merges the latest stable upstream release on `sync/<tag>`, builds it, moves `linux` forward and calls Linux release.                                  |

The upstream workflows (`ci.yml`, `codeql.yml`, `draft-release.yml`,
`release-pr.yml`, the triage workflows) stay in the tree so merges stay clean,
and are disabled in the repository settings.

Releases are created as drafts unless the repository variable
`PUBLISH_RELEASES` is `true`.

## When the sync opens an issue

[`script/linux/merge-upstream.sh`](../../script/linux/merge-upstream.sh) settles
the conflicts every merge has: the versions in `package.json` and
`app/package.json` (a JSON 3-way merge in
[`merge-package-json.mjs`](../../script/linux/merge-package-json.mjs)) and the
lockfiles (upstream's, then `yarn install --ignore-scripts`). Anything else is
a real conflict, and the workflow opens an issue labelled `upstream-sync` that
lists the files.

To fix it:

```sh
git fetch --no-tags https://github.com/desktop/desktop.git "refs/tags/$TAG:refs/tags/$TAG"
git switch -c "sync/$TAG" origin/linux
script/linux/merge-upstream.sh "$TAG"
# resolve the listed files: keep upstream's change and the Linux behaviour
git add <files>
git commit --no-edit
yarn install --frozen-lockfile && yarn build:dev && yarn test:unit
```

Open a pull request into `linux` with "Fixes #<issue>". Merge it with a merge
commit, not squash or rebase, so the upstream tag stays an ancestor of `linux`.
The version bump in the merge triggers Linux release.

Tips:

- `git log -p release-<previous>..$TAG -- <file>` shows what upstream changed.
- `git log -p --first-parent origin/linux -- <file>` shows the Linux changes.
- Most Linux code is guarded by `__LINUX__` or lives in files named `*linux*`;
  keep those and take upstream's version everywhere else.

## Linux-only fixes

Change the code on a branch, bump the suffix in `app/package.json`
(`3.6.6-linux1` → `3.6.6-linux2`) and open a pull request into `linux`. When it
is merged, Linux release publishes `release-3.6.6-linux2`. The next upstream
merge resets the suffix to `-linux1`.

## Checking a build by hand

```sh
yarn build:prod && yarn package
script/linux/smoke-test.sh dist/github-desktop-linux-x64/github-desktop
script/linux/aur/make-pkgbuild.sh "$(node -p "require('./app/package.json').version")" dist
```
