@echo on
setlocal EnableDelayedExpansion

setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo sed -i 's/        cc^) toolname="gcc";;/        *-cc^) toolname="gcc";;\n        cc^) toolname="gcc";;/' configure
echo sed -i 's/        c++^) toolname="gxx";;/        *-c++^) toolname="gxx";;\n        c++^) toolname="gxx";;/' configure
echo ./configure --kind=shared --prefix="%PREFIX%"
echo make -j%CPU_COUNT%
echo make install PREFIX="%PREFIX%"
) > _build.sh
endlocal

bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
