@echo on
setlocal EnableExtensions

rem First lay out the embedded MSIs. Running the bundle directly is unreliable
rem on CI workers that already have the same Swift bundle registered.
mkdir "%SRC_DIR%\layout"
start /wait "" "%SRC_DIR%\swift-installer.exe" /quiet /norestart /layout "%SRC_DIR%\layout"
if errorlevel 1 exit /b %errorlevel%

rem Administratively extract only the native no-assert compiler, command-line
rem tools, runtime, and Windows SDK. This avoids modifying the worker's MSI
rem registration and excludes IDE, debugger, Python, and Android payloads.
for %%M in (bld.noasserts.msi cli.noasserts.msi rtl.msi windows.msi) do (
  start /wait "" msiexec.exe /a "%SRC_DIR%\layout\%%M" /qn TARGETDIR="%PREFIX%" INSTALLROOT="%PREFIX%" INSTALLAMD64SDK=1 INSTALLAMD64REDIST=1 INSTALLX86SDK=0 INSTALLX86REDIST=0 INSTALLARM64SDK=0 INSTALLARM64REDIST=0
  if errorlevel 1 exit /b 1
)

if not exist "%PREFIX%\Toolchains\*\usr\bin\swiftc.exe" exit /b 1

mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\activate-swift.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\deactivate-swift.bat"
copy "%RECIPE_DIR%\LICENSE.txt" "%SRC_DIR%\LICENSE.txt"

endlocal
