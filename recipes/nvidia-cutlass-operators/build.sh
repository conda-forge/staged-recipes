#!/bin/bash
set -ex

mkdir -p "$SP_DIR"

# The archive wraps both directories below in its own site-packages/, so the
# paths here are relative to that rather than to the top of $SRC_DIR.
#
# Pure Python source. The package directory goes into site-packages as it is.
# There is no cutlass/__init__.py in it: `cutlass` belongs to nvidia-cutlass-dsl, and this
# archive only carries the cutlass/operators subtree.
cp -vrp site-packages/cutlass "$SP_DIR/"

# nvidia-cutlass-dsl ships `cutlass` as a regular package with
# __init__.py. It holds a hard-coded allowlist
# of sibling distributions, currently just "nvidia-cutlass-operators".
# Therefore the metadata directory has to be installed.
cp -vrp site-packages/nvidia_cutlass_operators-*.dist-info "$SP_DIR/"

test -d "$SP_DIR/cutlass/operators"
test -f "$SP_DIR"/nvidia_cutlass_operators-*.dist-info/METADATA

# Guard against the upstream archive gaining a cutlass/__init__.py. That would
# make this directory a regular package, and site-packages is searched before
# the nvidia_cutlass_dsl/dsl_packages entry, so it would shadow
# nvidia-cutlass-dsl's own `cutlass` and hide everything under it.
test ! -f "$SP_DIR/cutlass/__init__.py"
