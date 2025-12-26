#!/bin/bash
set -x

# build bindgen directory
cd rust
cargo build --release -p bindgen --target wasm32-wasip1
cd ..

# build the wasm.component
cargo install wasm-tools
wasm-tools component new ./rust/target/wasm32-wasip1/release/bindgen.wasm --adapt wasi_snapshot_preview1=./ci/wasi_snapshot_preview1.reactor.wasm -o ./rust/target/component.wasm

# bootstrapping with native platform
cd rust
cargo run -p=bindgen --features=cli ./target/component.wasm ../wasmtime/bindgen/generated
cd ..

$PYTHON -m pip install . -vv  --no-deps --no-build-isolation
