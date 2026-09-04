@echo off
:: GUI half of the split: the Qt-based nsys-ui timeline viewer.
setlocal enabledelayedexpansion

:: 2025.1.3.140 -> 2025.1.3, the directory NVIDIA creates inside the archive.
for /f "tokens=1,2,3 delims=." %%a in ("%PKG_VERSION%") do set "version_short=%%a.%%b.%%c"

:: See build_cli.bat: the top-level directory may or may not have been stripped.
set "archive_root=."
if not exist "nsight-systems\!version_short!" (
    for /d %%d in (*) do if exist "%%d\nsight-systems\!version_short!" set "archive_root=%%d"
)
set "payload=!archive_root!\nsight-systems\!version_short!"
if not exist "!payload!" (
    echo could not locate nsight-systems\!version_short! in the extracted archive
    exit 1
)

:: See build_cli.bat: cross-target collector and UCRT stubs are not shipped.
if exist "!payload!\target-linux-x64" rmdir /q /s "!payload!\target-linux-x64"
if exist "!payload!\lib32" rmdir /q /s "!payload!\lib32"
if exist "!payload!\lib64" rmdir /q /s "!payload!\lib64"

:: Shares an install root with nsight-systems-cli, which owns target-windows-x64
:: and documentation.
set "dest=%LIBRARY_PREFIX%\nsight-systems\!version_short!"
if not exist "!dest!" mkdir "!dest!"
if errorlevel 1 exit 1

move "!payload!\host-windows-x64" "!dest!\" || exit 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"

set "shim_dir=%%~dp0..\Library\nsight-systems\!version_short!\host-windows-x64"
set "shim_args=%%*"

:: See build_cli.bat for why this loop is not recursive and why sqlite3 is excluded.
for %%f in ("!dest!\host-windows-x64\*.exe") do (
    set "exe_name=%%~nf"
    set "skip="
    for %%x in (python sqlite3) do if /i "!exe_name!"=="%%x" set "skip=1"
    if not defined skip (
        > "%SCRIPTS%\!exe_name!.bat" echo @echo off
        >>"%SCRIPTS%\!exe_name!.bat" echo "!shim_dir!\!exe_name!.exe" !shim_args!
        if errorlevel 1 exit 1
    )
)

:: about.license_file resolves against the work directory root.
if /i not "!archive_root!"=="." copy /y "!archive_root!\LICENSE" LICENSE >nul
