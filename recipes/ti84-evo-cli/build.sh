#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

./gradlew cliJar --no-daemon --no-build-cache --no-watch-fs

install -d "${PREFIX}/share/ti84-evo" "${PREFIX}/bin" "${PREFIX}/Scripts"
install -m 0644 build/libs/ti84-evo-cli.jar "${PREFIX}/share/ti84-evo/ti84-evo-cli.jar"
install -m 0644 src/cli/scripts/ti84-evo.ps1 "${PREFIX}/share/ti84-evo/ti84-evo.ps1"
install -m 0755 packaging/conda/ti84-evo "${PREFIX}/bin/ti84-evo"
install -m 0644 packaging/conda/ti84-evo.bat "${PREFIX}/Scripts/ti84-evo.bat"
