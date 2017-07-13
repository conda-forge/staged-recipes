set DATA_DIR="%SP_DIR%\matplotlib\mpl-data"

if not exist %DATA_DIR% mkdir %DATA_DIR%

robocopy %SRC_DIR%\lib\matplotlib\mpl-data\sample_data %DATA_DIR% * /E
if %ERRORLEVEL% GTR 3 exit 1
