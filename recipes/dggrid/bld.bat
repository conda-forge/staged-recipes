mkdir build_cpp
cd build_cpp

cmake %SRC_DIR% -G "NMake Makefiles" ^
                -DCMAKE_PREFIX_PATH="%PREFIX%" ^
                -DWITH_EXT_SHAPELIB=ON ^
                -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

REM nmake install
REM if errorlevel 1 exit 1

copy src\apps\dggrid\dggrid %PREFIX%\Library\bin\dggrid.exe
if errorlevel 1 exit 1
