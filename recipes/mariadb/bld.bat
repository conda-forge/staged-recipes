@echo on

set "MARIADB_CC_LIB=%PREFIX%\Library\lib\mariadb"
set "MARIADB_CC_LIBRARY=%PREFIX%\Library\include\mariadb"

setx PATH "%PATH%;%MARIADB_CC_LIB%;%MARIADB_CC_LIBRARY%"

set "SKIP_VENDOR=1"

set "MARIADB_CC_INSTALL_DIR=%PREFIX%\Library\include\mariadb"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation