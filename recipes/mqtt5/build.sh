#!/usr/bin/env bash

set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
export OPENSSL_DIR=$PREFIX
export PYTHONIOENCODING="utf-8"

# rust-lld (LLD) cannot handle some of the relocations GCC emits for ppc64le
# (e.g. inline-PLT R_PPC64_PLTSEQ/PLTCALL), which breaks linking of C-based
# crates such as aws-lc-sys and libdbus-sys. Fall back to the GNU bfd linker on
# that platform, which handles these relocations. gcc honors the last
# -fuse-ld, so this overrides rustc's bundled rust-lld default.
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS:-} -C link-arg=-fuse-ld=bfd"
fi

# Use native-tls on conda-forge
export MATURIN_PEP517_ARGS="--no-default-features"

# Run the maturin build via pip which works for direct and
# cross-compiled builds.
$PYTHON -m pip install -v --use-pep517 --no-deps --no-build-isolation .

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
