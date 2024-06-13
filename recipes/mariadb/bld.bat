@echo on

set "MARIADB_CC_INSTALL_DIR=%PREFIX%\Library\lib\mariadb"
set "MARIADB_CC_INCLUDE_DIR=%PREFIX%\include\mariadb"
set "MARIADB_CC_LIB_DIR=%PREFIX%\lib\mariadb"

%PYTHON% -m pip install . --no-deps --verbose