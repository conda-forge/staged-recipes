setlocal EnableDelayedExpansion

cd %SRC_DIR%

set "CMAKE_GENERATOR=NMake Makefiles"

%PYTHON% -m pip install . -vv