#!/usr/bin/bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_root=$(cd -- "${script_dir}/../.." && pwd -P)
pkgver=$(sed -n 's/^version = "\([^"]*\)"/\1/p' "${source_root}/Cargo.toml" | sed -n '1p')
[[ -n ${pkgver} ]]

stage_root=$(mktemp -d -p /tmp agentos-hello-package.XXXXXX)
trap 'rm -rf -- "${stage_root}"' EXIT
stage_source=${stage_root}/agentos-hello-${pkgver}
mkdir -p -- "${stage_source}"
rsync -a \
  --exclude '/.git' \
  --exclude '/build/' \
  --exclude '/target/' \
  --exclude '/packaging/arch/pkg/' \
  --exclude '/packaging/arch/src/' \
  --exclude '/packaging/arch/.cargo-target*/' \
  --exclude '/packaging/arch/*.pkg.tar.*' \
  --exclude '/packaging/arch/agentos-hello-*.tar.*' \
  "${source_root}/" "${stage_source}/"

archive=${script_dir}/agentos-hello-${pkgver}.tar.zst
rm -f -- "${archive}"
bsdtar -caf "${archive}" -C "${stage_root}" "agentos-hello-${pkgver}"
cd -- "${script_dir}"
makepkg --cleanbuild --clean --force --noconfirm --syncdeps "$@"
