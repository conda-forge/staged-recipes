#!/bin/bash

# Make libR findable for Cargo and R wrapper scripts
export RUSTFLAGS="-C link-arg=-L${PREFIX}/lib/R/lib ${RUSTFLAGS}"
export LD_LIBRARY_PATH="${PREFIX}/lib/R/lib:${LD_LIBRARY_PATH:-}"
export DYLD_LIBRARY_PATH="${PREFIX}/lib/R/lib:${DYLD_LIBRARY_PATH:-}"

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}

# Bundle third party licenses from statically linked crates
pushd src/rust
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
popd
