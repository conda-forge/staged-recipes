#!/bin/bash
set -ex

# Temporary solution for ecl not producing code compatible with C23
sed -i 's/(require :kenzo)/(require :cmp)\n(setq c::*user-cc-flags* "-std=gnu17")\n(require :kenzo)/' compile.lisp

ecl < compile.lisp

ECL_SYS_PATH=$(ecl -norc -eval '(princ (namestring (translate-logical-pathname "sys:")))' -eval '(quit)')
ECL_DIR_NAME=$(basename "$ECL_SYS_PATH")
TARGET_DIR="$PREFIX/lib/$ECL_DIR_NAME"
mkdir -p "$TARGET_DIR"

cp -f kenzo--all-systems.fasb "$TARGET_DIR/kenzo.fas"
