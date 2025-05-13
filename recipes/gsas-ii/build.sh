#!/bin/bash
set -ex

mkdir builddir

# HACK: extend $CONDA_PREFIX/meson_cross_file that's created in
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/blob/main/recipe/activate-gcc.sh
# https://github.com/conda-forge/clang-compiler-activation-feedstock/blob/main/recipe/activate-clang.sh
# to use host python; requires that [binaries] section is last in meson_cross_file
echo "python = '${PREFIX}/bin/python'" >> ${CONDA_PREFIX}/meson_cross_file.txt

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -wnx -Cbuild-dir=builddir || (cat builddir/meson-logs/meson-log.txt && exit 1)
$PYTHON -m pip install --find-links dist gsas_ii
