call %RECIPE_DIR%/build_devel.bat
echo "****************************"
echo "DELETING files from devel except shared libraries"
echo "****************************"

rd /s /q %LIBRARY_PREFIX%/share
rd /s /q %LIBRARY_PREFIX%/include
rd /s /q %LIBRARY_PREFIX%/bin
rd /s /q %LIBRARY_PREFIX%/lib/pkg-config
rd /s /q %LIBRARY_PREFIX%/lib/libcantera.a
