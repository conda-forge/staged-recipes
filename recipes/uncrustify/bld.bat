:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

mkdir build
cd build
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBUILD_SHARED_LIBS=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Move the output to the correct locations.
mkdir "%LIBRARY_PREFIX%\bin"
move "%LIBRARY_PREFIX%\uncrustify.exe" "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1

:: Remove extra output.
del /f "%LIBRARY_PREFIX%\README.md"
del /f "%LIBRARY_PREFIX%\BUGS"
del /f "%LIBRARY_PREFIX%\ChangeLog"
rd /s /q "%LIBRARY_PREFIX%\cfg" "%LIBRARY_PREFIX%\doc"
if errorlevel 1 exit 1
