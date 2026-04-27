#!/bin/bash
set -euxo pipefail

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS:-}

# Ship conda activation hooks so `Rapp::install_pkg_cli_apps()` installs
# launchers into the active env's bin dir instead of the user-global
# ~/.local/bin (or %LOCALAPPDATA%\Programs\R\Rapp\bin on Windows).
for d in activate deactivate; do
    mkdir -p "${PREFIX}/etc/conda/${d}.d"
    cp "${RECIPE_DIR}/${d}.sh"  "${PREFIX}/etc/conda/${d}.d/r-rapp.sh"
    cp "${RECIPE_DIR}/${d}.bat" "${PREFIX}/etc/conda/${d}.d/r-rapp.bat"
    cp "${RECIPE_DIR}/${d}.ps1" "${PREFIX}/etc/conda/${d}.d/r-rapp.ps1"
done
