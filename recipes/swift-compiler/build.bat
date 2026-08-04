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
move /y "%SRC_DIR%\layout\a1" "%SRC_DIR%\layout\bld.noasserts.msi"
move /y "%SRC_DIR%\layout\a3" "%SRC_DIR%\layout\cli.noasserts.msi"
move /y "%SRC_DIR%\layout\a9" "%SRC_DIR%\layout\rtl.msi"
move /y "%SRC_DIR%\layout\a11" "%SRC_DIR%\layout\windows.msi"
move /y "%SRC_DIR%\layout\a13" "%SRC_DIR%\layout\bld.noasserts.cab"
move /y "%SRC_DIR%\layout\a15" "%SRC_DIR%\layout\cli.noasserts.cab"
move /y "%SRC_DIR%\layout\a21" "%SRC_DIR%\layout\rtl.cab"
move /y "%SRC_DIR%\layout\a27" "%SRC_DIR%\layout\windows.cab"
move /y "%SRC_DIR%\layout\a28" "%SRC_DIR%\layout\sdk.windows.arm64.cab"
move /y "%SRC_DIR%\layout\a29" "%SRC_DIR%\layout\sdk.windows.x64.cab"
move /y "%SRC_DIR%\layout\a30" "%SRC_DIR%\layout\sdk.windows.x86.cab"
move /y "%SRC_DIR%\layout\a31" "%SRC_DIR%\layout\windows.experimental.cab"
move /y "%SRC_DIR%\layout\a32" "%SRC_DIR%\layout\sdk.windows.experimental.arm64.cab"
move /y "%SRC_DIR%\layout\a33" "%SRC_DIR%\layout\sdk.windows.experimental.x64.cab"
move /y "%SRC_DIR%\layout\a34" "%SRC_DIR%\layout\sdk.windows.experimental.x86.cab"

rem Administratively extract only the native no-assert compiler, command-line
rem tools, runtime, and Windows SDK. Use a short path because the platform SDK
rem contains filenames which exceed MAX_PATH under rattler-build's work path.
for %%D in ("%SRC_DIR%") do set "SWIFT_ADMIN=%%~dD\swift-admin"
rmdir /S /Q "!SWIFT_ADMIN!" 2>nul
mkdir "!SWIFT_ADMIN!"
for %%M in (bld.noasserts.msi cli.noasserts.msi rtl.msi windows.msi) do (
  set "SWIFT_MSI=%SRC_DIR%\layout\%%M"
  if not exist "!SWIFT_MSI!" exit /b 1
  mkdir "!SWIFT_ADMIN!\%%~nM"
  start /wait "" msiexec.exe /a "!SWIFT_MSI!" /qn /l*v "!SWIFT_ADMIN!\%%~nM.log" TARGETDIR="!SWIFT_ADMIN!\%%~nM" INSTALLROOT="!SWIFT_ADMIN!\%%~nM" INSTALLAMD64SDK=1 INSTALLAMD64REDIST=1 INSTALLX86SDK=0 INSTALLX86REDIST=0 INSTALLARM64SDK=0 INSTALLARM64REDIST=0
  if errorlevel 1 (
    type "!SWIFT_ADMIN!\%%~nM.log"
    exit /b 1
  )
  if /i "%%M"=="rtl.msi" (
    rem The runtime MSI targets TARGETDIR directly. Library\bin is on conda's
    rem standard Windows PATH without exposing Swift's private Clang binaries.
    mkdir "%PREFIX%\Library\bin"
    xcopy /E /I /Y "!SWIFT_ADMIN!\%%~nM\*" "%PREFIX%\Library\bin\"
  ) else (
    xcopy /E /I /Y "!SWIFT_ADMIN!\%%~nM\LocalApp\Programs\Swift\*" "%PREFIX%\"
  )
  if errorlevel 1 exit /b 1
)
rmdir /S /Q "!SWIFT_ADMIN!"

set "SWIFTC_FOUND="
for /d %%T in ("%PREFIX%\Toolchains\*") do (
  if exist "%%T\usr\bin\swiftc.exe" set "SWIFTC_FOUND=1"
)
if not defined SWIFTC_FOUND exit /b 1

rem Keep the bundled LLVM tools off PATH and expose only Swift-facing commands.
mkdir "%PREFIX%\Scripts"
for %%T in (sourcekit-lsp swift swift-build swift-format swift-package swift-run swift-test swiftc) do (
  copy "%RECIPE_DIR%\swift-launcher.bat" "%PREFIX%\Scripts\%%T.bat"
)

mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\activate-swift.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\deactivate-swift.bat"
copy "%RECIPE_DIR%\LICENSE.txt" "%SRC_DIR%\LICENSE.txt"

endlocal
