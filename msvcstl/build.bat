@echo on
setlocal enableextensions
setlocal enabledelayedexpansion

set target_architecture=x64
set target_folder=amd64
if %host_platform% == "win-arm64" (
    set target_architecture=arm64
    set target_folder=arm64
)

cmake -S . -B build -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCONFIGURE_TESTING=True ^
    -DTESTS_BUILD_ONLY=False ^
    -DVCLIBS_SUFFIX="_conda" ^
    -DVCLIBS_TARGET_ARCHITECTURE=%target_architecture% ^
    %CMAKE_ARGS% || goto :error

cmake --build build || goto :error

mkdir "%LIBRARY_LIB%"
mkdir "%LIBRARY_INC%\c++\v1"
mkdir "%LIBRARY_PREFIX%\modules"

copy "build\out\bin\%target_folder%\*" "%LIBRARY_BIN%" || goto :error
copy "build\out\lib\%target_folder%\*" "%LIBRARY_LIB%" || goto :error
copy "build\out\inc\*" "%LIBRARY_INC%\c++\v1" || goto :error
copy "build\out\modules\*" "%LIBRARY_PREFIX%\modules" || goto :error

goto :eof

:error
echo Failed with error#%errorlevel%.
exit 1
