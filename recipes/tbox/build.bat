@echo on
setlocal EnableDelayedExpansion

setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo sed -i 's/raise "unknown tool ${1}"/toolname="gcc"/' configure
echo ./configure --kind=shared --prefix="%PREFIX%"
echo make -j%CPU_COUNT%
echo make install PREFIX="%PREFIX%"
) > _build.sh
endlocal

bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
