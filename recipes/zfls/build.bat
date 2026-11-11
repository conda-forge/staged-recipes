@echo on
setlocal

:: Zig cross-compiles: build for the package's platform, not the build
:: machine's
if "%target_platform%"=="win-arm64" (
    set "TARGET=aarch64-windows"
) else (
    set "TARGET=x86_64-windows"
)

set "ZIG_GLOBAL_CACHE_DIR=%SRC_DIR%\.zig-global-cache"
set "ZIG_LOCAL_CACHE_DIR=%SRC_DIR%\.zig-cache"
:: zig is a batch file wrapper here: without call, this script would end with it
call zig build bin -Dtarget=%TARGET% -Doptimize=ReleaseSafe --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

:: Installed next to the binary, it makes zfls report a release candidate
:: version; a released zfls reports the plain one
del "%LIBRARY_BIN%\zfls.prerelease"
if errorlevel 1 exit 1
