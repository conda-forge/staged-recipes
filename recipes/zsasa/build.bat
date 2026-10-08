@echo on
setlocal enableextensions

if "%ZIG_TARGET%"=="" (
    echo recipe.yaml has no Zig target for %target_platform%; add it to zig_target
    exit /b 1
)

:: Keep both Zig caches inside the work directory (see build.sh).
set "ZIG_GLOBAL_CACHE_DIR=%SRC_DIR%\.zig-global-cache"
set "ZIG_LOCAL_CACHE_DIR=%SRC_DIR%\.zig-local-cache"

:: Hand the dependencies to Zig without network access (see build.sh).
:: zig is a .bat wrapper in the conda package, hence `call`.
for /d %%D in (zig-deps\*) do (
    call zig fetch "%%D"
    if errorlevel 1 exit /b 1
)

:: -Dcpu=baseline is x86-64-v1 here, not the CPU of the build machine.
:: Zig puts zsasa.exe and zsasa.dll in bin and the import library in lib.
call zig build ^
    --system "%SRC_DIR%\zig-pkg" ^
    --prefix "%LIBRARY_PREFIX%" ^
    -Doptimize=ReleaseFast ^
    -Dtarget=%ZIG_TARGET% ^
    -Dcpu=baseline ^
    --summary all
if errorlevel 1 exit /b 1

:: zsasa.exe and zsasa.dll share one name, so Zig writes a single zsasa.pdb
:: that can only describe one of them. Do not ship it.
if exist "%LIBRARY_BIN%\zsasa.pdb" del "%LIBRARY_BIN%\zsasa.pdb"
if errorlevel 1 exit /b 1
