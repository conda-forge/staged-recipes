#!/bin/bash
set -euo pipefail

# Compile Rust code:
make target/release/libpymemprofile_api.a

# Disable aligned_alloc(). On Linux, Conda uses ancient glibc headers from 2010
# where aligned_alloc is defined as inline function, rather than as overridable
# symbol. On macOS it's using ABI that is also too old to have it.
sed -i -e 's/SYMBOL_PREFIX.aligned_alloc/SYMBOL_PREFIX(no_aligned_alloc_on_conda/' filprofiler/_filpreload.c

# Build and install Python code:
export PIP_LOG=/dev/stdout
$PYTHON -m pip install . -vv
