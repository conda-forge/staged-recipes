#!/bin/bash
# Inspired by the numpy-feedstock build script:
# https://github.com/conda-forge/numpy-feedstock/blob/main/recipe/build.sh

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Ensure pipeline errors are captured
# set -u  # Treat unset variables as an error
set -x  # Print each command before executing it

mkdir builddir

# HACK: extend $CONDA_PREFIX/meson_cross_file that's created in
# Extend conda meson cross file to set python path
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/blob/main/recipe/activate-gcc.sh
# https://github.com/conda-forge/clang-compiler-activation-feedstock/blob/main/recipe/activate-clang.sh
# to use host python; requires that [binaries] section is last in meson_cross_file
echo "python = '${PREFIX}/bin/python'" >> ${CONDA_PREFIX}/meson_cross_file.txt

# Strip redundant --buildtype from MESON_ARGS to avoid meson errors
# meson-python already sets up a -Dbuildtype=release argument to meson, so
# we need to strip --buildtype out of MESON_ARGS or fail due to redundancy
MESON_ARGS_REDUCED="$(echo "$MESON_ARGS" | sed 's/--buildtype release //g')"

# Build the wheel
# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS_REDUCED// / -Csetup-args=} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)

# Install all wheels generated in dist/
pip install dist/*.whl

echo "[SUCCESS] Build and install completed successfully."