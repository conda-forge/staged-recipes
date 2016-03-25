if "%PY_VER%" == "2.7" (
    echo "OK"
) else (
    mkdir %LIBRARY_PREFIX%\share\basemap  || exit 1
)

xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\*_i.dat %LIBRARY_PREFIX%\share\basemap /s /e || exit 1
xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\*_h.dat %LIBRARY_PREFIX%\share\basemap /s /e || exit 1
xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\*_f.dat %LIBRARY_PREFIX%\share\basemap /s /e || exit 1
xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\UScounties.* %LIBRARY_PREFIX%\share\basemap /s /e || exit 1
