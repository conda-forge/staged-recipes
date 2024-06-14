@echo on

set "MARIADB_CC_LIB=%PREFIX%\Library\lib\mariadb"
set "MARIADB_CC_LIBRARY=%PREFIX%\Library\include\mariadb"
set "PATH=%PREFIX%\Library\lib\mariadb;%PREFIX%\Library\include\mariadb;%PATH%"
set "INCLUDE=%PREFIX%\Library\include\mariadb;%PREFIX%\Library\include;%PREFIX%\Library\include"
::setx PATH "%PATH%;%PREFIX%\Library\lib\mariadb;%PREFIX%\Library\include\mariadb"

set "SKIP_VENDOR=1"

set "MARIADB_CC_INSTALL_DIR=%PREFIX%\Library\include\mariadb"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation