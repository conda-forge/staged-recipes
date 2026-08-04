#!/bin/bash
mkdir -p "$PREFIX/bin"
rustc core/bin/zyra.rs -o "$PREFIX/bin/zyra"
