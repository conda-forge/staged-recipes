#!/usr/bin/env bash
set -ex

mkdir -p "$PREFIX/bin"
cp git-* "$PREFIX/bin"
chmod +x "$PREFIX/bin"/git-*
