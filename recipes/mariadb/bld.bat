@echo on

set MARIADB_CC_LIB = %PREFIX%\lib\mariadb
set MARIADB_CC_LIBRARY = %PREFIX%\include\mariadb

setx PATH "%PATH%;%MARIADB_CC_LIB%;%MARIADB_CC_LIBRARY%"

set "SKIP_VENDOR=1"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation