@echo on
setlocal EnableExtensions EnableDelayedExpansion

rem The WiX /layout switch preserves the bundle instead of unpacking its
rem embedded payloads. Extract the attached Burn cabinet, then unpack and name
rem only the MSIs and external cabinets needed by the native toolchain.
python "%RECIPE_DIR%\extract-burn.py" "%SRC_DIR%\swift-installer.exe" "%SRC_DIR%\attached.cab"
if errorlevel 1 exit /b 1
mkdir "%SRC_DIR%\layout"
7z x -y "%SRC_DIR%\attached.cab" -o"%SRC_DIR%\layout" a1 a3 a9 a11 a13 a15 a21 a27 a28 a29 a30 a31 a32 a33 a34
if errorlevel 1 exit /b 1
for %%P in (a1=bld.noasserts.msi a3=cli.noasserts.msi a9=rtl.msi a11=windows.msi a13=bld.noasserts.cab a15=cli.noasserts.cab a21=rtl.cab a27=windows.cab a28=sdk.windows.arm64.cab a29=sdk.windows.x64.cab a30=sdk.windows.x86.cab a31=windows.experimental.cab a32=sdk.windows.experimental.arm64.cab a33=sdk.windows.experimental.x64.cab a34=sdk.windows.experimental.x86.cab) do (
  for /f "tokens=1,2 delims==" %%A in ("%%P") do move /y "%SRC_DIR%\layout\%%A" "%SRC_DIR%\layout\%%B"
)

rem Administratively extract only the native no-assert compiler, command-line
rem tools, runtime, and Windows SDK. This avoids modifying the worker's MSI
rem registration and excludes IDE, debugger, Python, and Android payloads.
for %%M in (bld.noasserts.msi cli.noasserts.msi rtl.msi windows.msi) do (
  set "SWIFT_MSI=%SRC_DIR%\layout\%%M"
  if not exist "!SWIFT_MSI!" exit /b 1
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
