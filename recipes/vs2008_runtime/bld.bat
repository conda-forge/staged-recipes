if "%CI%" == "True" (
  vcredist.exe /qb!
)

if "%ARCH%" == "32" (
  set "ARCH_DIR=x86"
)

if "%ARCH%" == "64" (
  set "ARCH_DIR=amd64"
)

cd C:\Windows\WinSxS\%ARCH_DIR%_microsoft.vc90.openmp_*_%PKG_VERSION%_*
xcopy *.dll %LIBRARY_BIN%
xcopy *.dll %PREFIX%

cd C:\Windows\WinSxS\%ARCH_DIR%_microsoft.vc90.crt_*_%PKG_VERSION%_*
xcopy *.dll %LIBRARY_BIN%
xcopy *.dll %PREFIX%

cd %SRC_DIR%
