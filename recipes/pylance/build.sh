#!/usr/bin/env bash
set -ex

if [[ ("${target_platform}" == "win-64" && "${build_platform}" == "linux-64") ]]; then
  # Bundle all downstream library licenses
  cd python
  cargo-bundle-licenses \
    --format yaml \
    --output ${SRC_DIR}/THIRDPARTY.yml

  # Apply PEP517 to install the package
  maturin build \
    --release \
    --strip \
    --manylinux off \
    --interpreter="${PYTHON}"

  # Install wheel manually
  cd target/wheels
  "${PYTHON}" -m pip install *.whl \
    -vv \
    --no-deps \
    --target $PREFIX/lib/site-packages \
    --platform win_amd64
else
  # Run the maturin build via pip which works for direct and
  # cross-compiled builds.
  cd python
  $PYTHON -m pip install . -vv
fi