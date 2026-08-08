#!/bin/bash
mkdir -p "$PREFIX/bin"
rustc core/bin/zyra.rs -C linker="$CC" -o "$PREFIX/bin/zyra"
