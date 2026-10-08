#!/usr/bin/env bash
# Prints the AUR PKGBUILD for a release, filled in from the .deb files.
#
# Usage: make-pkgbuild.sh <version> <directory with the .deb files>

set -euo pipefail

version="$1"
dir="$2"

checksum() {
  sha256sum "$dir/GitHubDesktop-linux-$1-$version.deb" | cut -d' ' -f1
}

sed -e "s/@PKGVER@/${version//-/_}/" \
  -e "s/@SHA256_X86_64@/$(checksum amd64)/" \
  -e "s/@SHA256_AARCH64@/$(checksum arm64)/" \
  "$(dirname "$0")/PKGBUILD.in"
