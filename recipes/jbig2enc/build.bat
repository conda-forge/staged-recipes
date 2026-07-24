setlocal enabledelayedexpansion

:: Leptonica's Windows pkg-config/CMake exports aren't reliably
:: discoverable by Meson on MSVC (see meson.build patch). As a last
:: resort, auto-detect whatever import library was actually installed
:: and pass its name to meson explicitly, rather than guessing.
set "LEPT_OPT="
if exist "%LIBRARY_LIB%" (
    for %%F in ("%LIBRARY_LIB%\*lept*.lib") do (
        if not defined LEPT_OPT (
            set "LEPT_OPT=-Dleptonica_lib_name=%%~nF"
        )
    )
)

meson setup builddir ^
  --prefix="%LIBRARY_PREFIX%" ^
  --buildtype=release ^
  --wrap-mode=nofallback ^
  !LEPT_OPT!
if errorlevel 1 exit /b 1

if "%CPU_COUNT%"=="" set "CPU_COUNT=1"

meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit /b 1

meson install -C builddir
if errorlevel 1 exit /b 1

endlocal