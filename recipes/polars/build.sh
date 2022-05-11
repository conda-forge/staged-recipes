#!/bin/bash

set -ex

# See https://github.com/conda-forge/rust-feedstock/blob/master/recipe/build.sh for cc env explanation

if [ "$c_compiler" = gcc ] ; then
    case "$BUILD" in
        x86_64-*) rust_env_arch=X86_64_UNKNOWN_LINUX_GNU ;;
        aarch64-*) rust_env_arch=AARCH64_UNKNOWN_LINUX_GNU ;;
        powerpc64le-*) rust_env_arch=POWERPC64LE_UNKNOWN_LINUX_GNU ;;
        *) echo "unknown BUILD $BUILD" ; exit 1 ;;
    esac

    export CARGO_TARGET_${rust_env_arch}_LINKER=$CC
fi

declare -a _xtra_maturin_args
_xtra_maturin_args+=(--cargo-extra-args="-Zfeatures=itarget")

if [ "$target_platform" = "osx-arm64" ] && [ "$CONDA_BUILD_CROSS_COMPILATION" = "1" ] ; then
    # Install the standard host stuff for target platform
    cd ${SRC_DIR}/rust-nightly-aarch64-apple-darwin
    ./install.sh --verbose --prefix=${SRC_DIR}/rust-nightly-install --disable-ldconfig --components=rust-std*
    cd -

    mkdir $SRC_DIR/.cargo
    cat <<EOF >> $SRC_DIR/.cargo/config
# Required for intermediate codegen stuff
[target.x86_64-apple-darwin]
linker = "$CC_FOR_BUILD"
# Required for final binary artifacts for target
[target.aarch64-apple-darwin]
linker = "$CC"
rustflags = [
  "-C", "link-arg=-undefined",
  "-C", "link-arg=dynamic_lookup",
]
EOF
  _xtra_maturin_args+=(--target=aarch64-apple-darwin)

  # This variable must be set to the directory containing the target's libpython DSO
  export PYO3_CROSS_LIB_DIR=$PREFIX/lib

  # xref: https://github.com/PyO3/pyo3/commit/7beb2720
  export PYO3_PYTHON_VERSION=${PY_VER}
fi

cd ${SRC_DIR}/rust-nightly
./install.sh --verbose --prefix=${SRC_DIR}/rust-nightly-install --disable-ldconfig --components=rustc,cargo,rust-std*
cd -

export PATH=${SRC_DIR}/rust-nightly-install/bin:$PATH

maturin build --no-sdist --release --strip --manylinux off --interpreter="${PYTHON}" --rustc-extra-args="-C codegen-units=16 -C lto=thin -C target-cpu=native"

"${PYTHON}" -m pip install $SRC_DIR/target/wheels/polars*.whl --no-deps -vv

