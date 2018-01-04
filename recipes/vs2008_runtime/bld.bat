if "%ARCH%" == "32" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'vcredist_x86.exe')"
    if errorlevel 1 exit 1
    vcredist_x86.exe /qb!
    if errorlevel 1 exit 1
    set "ARCH_DIR=x86"
)


if "%ARCH%" == "64" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe', 'vcredist_x64.exe')"
    if errorlevel 1 exit 1
    vcredist_x64.exe /qb!
    if errorlevel 1 exit 1
    set "ARCH_DIR=amd64"
)

cd C:\Windows\WinSxS\%ARCH_DIR%_microsoft.vc90.openmp_*_%PKG_VERSION%_*
xcopy *.dll %LIBRARY_BIN%
xcopy *.dll %PREFIX%

cd C:\Windows\WinSxS\%ARCH_DIR%_microsoft.vc90.crt_*_%PKG_VERSION%_*
xcopy *.dll %LIBRARY_BIN%
xcopy *.dll %PREFIX%

cd %SRC_DIR%
