@echo on

set "MARIADB_CC_LIB=%PREFIX%\Library\lib\mariadb"
set "MARIADB_CC_LIBRARY=%PREFIX%\Library\include\mariadb"
set "PATH=%MARIADB_CC_LIB%;%MARIADB_CC_LIBRARY%;%PATH%"
set "INCLUDE=%MARIADB_CC_LIBRARY%;%MARIADB_CC_LIB%;%INCLUDE%"
set "SKIP_VENDOR=1"

set "LIB=%LIB%;%MARIADB_CC_LIB%"

set "MARIADB_CC_INSTALL_DIR=%MARIADB_CC_LIBRARY%"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation