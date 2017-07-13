set DATA_DIR="%SP_DIR%\matplotlib\mpl-data\sample_data"

if not exist %DATA_DIR% mkdir %DATA_DIR%

xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\*.* %DATA_DIR% /s /e || exit 1
