# GitHub Desktop for Linux (community build)

[![Linux CI](https://github.com/mihailinl/github-desktop-linux/actions/workflows/linux-ci.yml/badge.svg)](https://github.com/mihailinl/github-desktop-linux/actions/workflows/linux-ci.yml)
[![Upstream sync](https://github.com/mihailinl/github-desktop-linux/actions/workflows/linux-upstream-sync.yml/badge.svg)](https://github.com/mihailinl/github-desktop-linux/actions/workflows/linux-upstream-sync.yml)

Plain [GitHub Desktop](https://github.com/desktop/desktop) for Linux, kept up to
date with every stable upstream release. It is the same app as on Windows and
macOS, including worktrees (3.6 and later), with the Linux support from
[shiftkey/desktop](https://github.com/shiftkey/desktop), which stopped at 3.4.

This is an **unofficial** build. It is not affiliated with or endorsed by GitHub.

## Install

Download a file for your system from the
[latest release](https://github.com/mihailinl/github-desktop-linux/releases/latest).
Every release has x86_64 and arm64 builds.

| System                       | File                                                                       |
| ---------------------------- | -------------------------------------------------------------------------- |
| Any distribution             | `.AppImage`: `chmod +x` it and run it                                      |
| Debian, Ubuntu, Mint         | `.deb`: `sudo apt install ./GitHubDesktop-linux-amd64-<version>.deb`       |
| Fedora, openSUSE, RHEL       | `.rpm`: `sudo dnf install ./GitHubDesktop-linux-x86_64-<version>.rpm`      |
| Arch, CachyOS, Manjaro       | `PKGBUILD`: put it in an empty folder and run `makepkg -si`                |
| Anything else                | `.tar.gz`: unpack it and run `github-desktop` inside                       |

The `PKGBUILD` builds a package with the same name and paths as the AUR
`github-desktop-bin`, so it upgrades an existing install in place.

Saving your sign-in needs a Secret Service keyring: GNOME Keyring, or KWallet
on KDE Plasma 6. Most desktops start one for you; see the
[Arch Wiki](https://wiki.archlinux.org/title/GNOME/Keyring) if yours does not.

### Signing in when another Desktop app is installed

The browser hands the sign-in back to whichever app owns the
`x-github-desktop-auth` link. If you also have Desktop Plus or an older GitHub
Desktop installed, point the links at this one:

```sh
for scheme in x-github-client x-github-desktop-auth x-github-desktop-dev-auth; do
  xdg-mime default github-desktop.desktop "x-scheme-handler/$scheme"
done
```

## Verify a download

Every file is built by GitHub Actions from this repository, never on a
personal machine, and carries a signed
[build provenance attestation](https://docs.github.com/actions/security-for-github-actions/using-artifact-attestations):

```sh
gh attestation verify GitHubDesktop-linux-amd64-<version>.deb --repo mihailinl/github-desktop-linux
sha256sum -c SHA256SUMS --ignore-missing
```

## How updates work

The [upstream sync](workflows/linux-upstream-sync.yml) workflow checks for a
new stable GitHub Desktop release every 6 hours. When there is one, it merges
it, builds and tests the app on x86_64 and arm64, and publishes a release
named after it, such as `release-3.6.6-linux1`. Linux-only fixes bump the last
number (`-linux2`).

When upstream changes code that the Linux patches also touch, the merge needs a
person. The workflow then opens an
[`upstream-sync` issue](https://github.com/mihailinl/github-desktop-linux/issues?q=label%3Aupstream-sync)
and publishes nothing until it is fixed. The steps are in
[maintaining-linux-builds.md](../docs/process/maintaining-linux-builds.md).

To be told about new versions, click **Watch → Custom → Releases** at the top of
this page.

## Problems

- Something that also happens on Windows or macOS: report it to
  [desktop/desktop](https://github.com/desktop/desktop/issues).
- Something Linux-only: [open an issue here](https://github.com/mihailinl/github-desktop-linux/issues/new/choose).
- Common Linux problems and workarounds are in
  [known issues](../docs/known-issues.md#linux).

## Other options

[Desktop Plus](https://github.com/desktop-plus/desktop-plus) is a GitHub Desktop
fork with extra features, built from upstream beta releases. Choose it if you
want new features first; choose this build if you want stock GitHub Desktop.

## License

[MIT](../LICENSE), as upstream. The MIT license does not cover GitHub's
trademarks, including the logos in [app/static/logos](../app/static/logos).
GitHub® and the Invertocat mark are trademarks of GitHub, Inc.
