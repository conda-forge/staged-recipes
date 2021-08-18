#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC

rustc --version

if [[ $PKG_NAME == "oxigraph-server" ]]; then
    cd $SRC_DIR/server
    cargo build --release --verbose
    mkdir -p $PREFIX/bin
    cp $SRC_DIR/target/release/oxigraph_server $PREFIX/bin/
fi

if [[ $PKG_NAME == "oxigraph-wikibase" ]]; then
    cd $SRC_DIR/wikibase
    cargo build --release --verbose
    mkdir -p $PREFIX/bin
    cp $SRC_DIR/target/release/oxigraph_wikibase $PREFIX/bin/
fi

if [[ $PKG_NAME == "pyoxigraph" ]]; then
    cd $SRC_DIR/python
    maturin build --release -i $PYTHON
    $PYTHON -m pip install $SRC_DIR/target/wheels/*.whl
fi
