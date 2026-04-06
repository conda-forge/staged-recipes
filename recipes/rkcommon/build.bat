@echo off
setlocal enabledelayedexpansion

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=ON ^
    -DRKCOMMON_STRICT_BUILD=OFF ^
    -DRKCOMMON_WARN_AS_ERRORS=OFF ^
    -DRKCOMMON_TASKING_SYSTEM=TBB ^
    -DRKCOMMON_TBB_ROOT="%PREFIX%" ^
    -DINSTALL_DEPS=OFF
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest -V --test-dir build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
