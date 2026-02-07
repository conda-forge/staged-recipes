@echo on

REM Use _build to avoid conflict with Stim's BUILD directory
cmake %CMAKE_ARGS% -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -B _build ^
    .
if errorlevel 1 exit 1

cmake --build _build --target libstim
if errorlevel 1 exit 1

REM Manual install - cmake --install tries to install the stim executable too
if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"
if not exist "%LIBRARY_INC%" mkdir "%LIBRARY_INC%"
copy _build\out\libstim.lib "%LIBRARY_LIB%\stim.lib"
if errorlevel 1 exit 1
copy src\stim.h "%LIBRARY_INC%\"
if errorlevel 1 exit 1
