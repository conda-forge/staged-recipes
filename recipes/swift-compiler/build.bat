@echo on
setlocal EnableExtensions EnableDelayedExpansion

rem First lay out the embedded MSIs. Running the bundle directly is unreliable
rem on CI workers that already have the same Swift bundle registered.
mkdir "%SRC_DIR%\layout"
start /wait "" "%SRC_DIR%\swift-installer.exe" /quiet /norestart /layout "%SRC_DIR%\layout"
if errorlevel 1 exit /b 1

rem Administratively extract only the native no-assert compiler, command-line
rem tools, runtime, and Windows SDK. This avoids modifying the worker's MSI
rem registration and excludes IDE, debugger, Python, and Android payloads.
for %%M in (bld.noasserts.msi cli.noasserts.msi rtl.msi windows.msi) do (
  set "SWIFT_MSI="
  rem FOR /R with a literal set fabricates that name in every directory;
  rem enumerate real files and select the requested MSI instead.
  for /r "%SRC_DIR%\layout" %%F in (*) do (
    if /i "%%~nxF"=="%%M" set "SWIFT_MSI=%%F"
  )
  if not defined SWIFT_MSI exit /b 1
  mkdir "%SRC_DIR%\admin\%%~nM"
  start /wait "" msiexec.exe /a "!SWIFT_MSI!" /qn /l*v "%SRC_DIR%\admin\%%~nM.log" TARGETDIR="%SRC_DIR%\admin\%%~nM" INSTALLROOT="%SRC_DIR%\admin\%%~nM" INSTALLAMD64SDK=1 INSTALLAMD64REDIST=1 INSTALLX86SDK=0 INSTALLX86REDIST=0 INSTALLARM64SDK=0 INSTALLARM64REDIST=0
  if errorlevel 1 (
    type "%SRC_DIR%\admin\%%~nM.log"
    exit /b 1
  )
  xcopy /E /I /Y "%SRC_DIR%\admin\%%~nM\*" "%PREFIX%\"
  if errorlevel 1 exit /b 1
)

if not exist "%PREFIX%\Toolchains\*\usr\bin\swiftc.exe" exit /b 1

mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\activate-swift.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\deactivate-swift.bat"
copy "%RECIPE_DIR%\LICENSE.txt" "%SRC_DIR%\LICENSE.txt"

endlocal
