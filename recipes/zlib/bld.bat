mkdir build
cd build

REM Configure step
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

REM Some OSS libraries are happier if z.lib exists, even though it's not typical on Windows
copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\z.lib
REM Qt in particular goes looking for this one (As of 4.8.7)
copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\zdll.lib
