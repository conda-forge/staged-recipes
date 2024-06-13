@echo on

set "MARIADB_CC_INSTALL_DIR=%PREFIX%\Library\lib\mariadb"
set "MARIADB_CC_INCLUDE_DIR=%PREFIX%\Library\include\mariadb"
set "MARIADB_CC_LIB_DIR=%PREFIX%\lib\mariadb"
set "SKIP_VENDOR=1"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation