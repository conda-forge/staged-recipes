setlocal EnableDelayedExpansion

cd %SRC_DIR%

set "CMAKE_GENERATOR=NMake Makefiles"

if exist photochem-%PKG_VERSION%_withdata (
  move photochem-%PKG_VERSION%_withdata\* .
)

%PYTHON% -m pip install . -vv