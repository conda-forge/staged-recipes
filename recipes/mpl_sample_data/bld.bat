set DATA_DIR="%SP_DIR%\matplotlib\mpl-data"

if not exist %DATA_DIR% mkdir %DATA_DIR%

xcopy /e /i %SRC_DIR%\lib\matplotlib\mpl-data\sample_data\ %DATA_DIR% || exit
