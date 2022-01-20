#!/usr/bin/env bash
set -eux

# Install just
cargo install just


# python_target="python3.8" # Will parameterize this
# arch_target="x86_64-unknown-linux-gnu" # Will parameterize this
# just build-wheel api $python_target $arch_target
# just build-wheel compiler-cranelift $python_target $arch_target

just build api
just build compiler-cranelift
# python examples/appendices/simple.py