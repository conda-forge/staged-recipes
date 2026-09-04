@echo off
:: CLI half of the split: the target-side collector (nsys) plus the documentation.
setlocal enabledelayedexpansion

:: 2025.1.3.140 -> 2025.1.3, the directory NVIDIA creates inside the archive.
for /f "tokens=1,2,3 delims=." %%a in ("%PKG_VERSION%") do set "version_short=%%a.%%b.%%c"

:: Whether the archive's single top-level directory is stripped during extraction can
:: differ, so locate the payload rather than assuming it sits at the work-dir root.
set "archive_root=."
if not exist "nsight-systems\!version_short!" (
    for /d %%d in (*) do if exist "%%d\nsight-systems\!version_short!" set "archive_root=%%d"
)
set "payload=!archive_root!\nsight-systems\!version_short!"
if not exist "!payload!" (
    echo could not locate nsight-systems\!version_short! in the extracted archive
    exit 1
)

:: The Windows archive also carries a Linux target collector (~497 MB) so a Windows
:: host can profile a Linux target remotely, plus the UCRT redistributable stubs that
:: a conda environment already provides. Neither is shipped.
if exist "!payload!\target-linux-x64" rmdir /q /s "!payload!\target-linux-x64"
if exist "!payload!\lib32" rmdir /q /s "!payload!\lib32"
if exist "!payload!\lib64" rmdir /q /s "!payload!\lib64"

set "dest=%LIBRARY_PREFIX%\nsight-systems\!version_short!"
if not exist "!dest!" mkdir "!dest!"
if errorlevel 1 exit 1

move "!payload!\target-windows-x64" "!dest!\" || exit 1
move "!payload!\documentation" "!dest!\" || exit 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"

:: Shim bodies are built here, outside the for loop, so that `%%` is unambiguously
:: an escaped percent sign rather than a loop-variable reference.
set "shim_dir=%%~dp0..\Library\nsight-systems\!version_short!\target-windows-x64"
set "shim_args=%%*"

:: A .bat launcher per shipped executable. The loop is deliberately NOT recursive:
:: every shim points at !shim_dir!\<name>.exe, so recursing would emit shims with
:: paths that don't resolve for any executable nested in a subdirectory.
:: sqlite3.exe is excluded because it also ships in the GUI half (the two packages
:: would clobber each other's shim in Scripts\) and because a sqlite3.bat on PATH
:: would shadow the environment's real sqlite3.
for %%f in ("!dest!\target-windows-x64\*.exe") do (
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
