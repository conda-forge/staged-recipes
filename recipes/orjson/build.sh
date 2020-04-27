#!/bin/bash

set -ex

./install.sh --prefix=$PREFIX

# Fun times -- by default, Rust/Cargo tries to link executables on Linux by
# invoking `cc`. An executable of this name is not necessarily available. By
# setting a magic environment variable, we can override this default.

if [ "$c_compiler" = gcc ] ; then
    case "$BUILD" in
        x86_64-*) rust_env_arch=X86_64_UNKNOWN_LINUX_GNU ;;
        aarch64-*) rust_env_arch=AARCH64_UNKNOWN_LINUX_GNU ;;
        powerpc64le-*) rust_env_arch=POWERPC64LE_UNKNOWN_LINUX_GNU ;;
        *) echo "unknown BUILD $BUILD" ; exit 1 ;;
    esac

    export CARGO_TARGET_${rust_env_arch}_LINKER=\$CC
fi

${SRC_DIR}/rust-nightly/install.sh --verbose --prefix=${SRC_DIR}/rust-nightly-install --disable-ldconfig
export PATH=${SRC_DIR}/rust-nightly-install/bin:$PATH
maturin build --no-sdist --release --strip --manylinux off
"${PYTHON}" -m pip install . -vv