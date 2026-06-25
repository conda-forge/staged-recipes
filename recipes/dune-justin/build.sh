#!/bin/bash
# justIN install. The project has no setup.py -- it is command-line clients
# (commands/) plus job-side utilities (jobutils/). Mirror the spack recipe:
#   install_tree(commands -> prefix.bin); install_tree(jobutils -> prefix.jobutils)
#   makedirs(prefix.man.man1); mv prefix.bin/*.1 -> man1
# (man pages live inside commands/, so they land in bin first and get moved out;
#  we use the conda-standard share/man/man1 rather than spack's prefix/man/man1.)
set -euo pipefail

mkdir -p "${PREFIX}/bin" "${PREFIX}/jobutils" "${PREFIX}/share/man/man1"

# Command-line clients (justin, justin-cvmfs-upload, ...) -> bin/ (preserve +x).
cp -a "${SRC_DIR}"/commands/. "${PREFIX}/bin/"

# Job-side utilities shipped to grid jobs -> prefix/jobutils (mirrors spack's
# prefix.jobutils; only bin/ goes on PATH).
cp -a "${SRC_DIR}"/jobutils/. "${PREFIX}/jobutils/"

# Relocate the *.1 man pages out of bin/ into man/man1.
mv "${PREFIX}"/bin/*.1 "${PREFIX}/share/man/man1/"
