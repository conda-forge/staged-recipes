@echo on
setlocal EnableExtensions EnableDelayedExpansion

rem Administratively extract the native no-assert compiler, command-line tools
rem and Windows platform SDK. The runtime MSI is packaged by swift-runtime.
for %%D in ("%SRC_DIR%") do set "SWIFT_ADMIN=%%~dD\swift-admin"
set "SWIFT_ROOT=%PREFIX%\Library\swift"
mkdir "%SWIFT_ROOT%"
python "%RECIPE_DIR%\extract-burn.py" "%SRC_DIR%\swift-installer.exe" "%SRC_DIR%\layout" bld.noasserts.msi cli.noasserts.msi windows.msi
if errorlevel 1 exit /b 1
for %%M in (bld.noasserts.msi cli.noasserts.msi windows.msi) do (
  call "%RECIPE_DIR%\admin-install.bat" %%M
  if errorlevel 1 exit /b 1
  set "SWIFT_MSI_ROOT=!SWIFT_ADMIN!\%%~nM\LocalApp\Programs\Swift"
  if not exist "!SWIFT_MSI_ROOT!" exit /b 1

  rem Administrative installs ignore feature selection, so remove the arm64
  rem and x86 SDKs, and the redistributable merge modules, explicitly.
  rmdir /S /Q "!SWIFT_MSI_ROOT!\Redistributables" 2>nul
  rem FOR /R cannot take a delayed-expansion root, so walk the current directory.
  pushd "!SWIFT_MSI_ROOT!"
  for /d /r %%A in (aarch64 i686 bin32 bin64a) do (
    if exist "%%A" rmdir /S /Q "%%A"
  )
  for /r %%F in (aarch64-unknown-windows-msvc.* i686-unknown-windows-msvc.*) do (
    del /F /Q "%%F"
  )
  popd

  xcopy /E /I /Y /Q "!SWIFT_MSI_ROOT!\*" "%SWIFT_ROOT%\"
  if errorlevel 1 exit /b 1
)
rmdir /S /Q "%SWIFT_ADMIN%"

set "SWIFTC_FOUND="
for /d %%T in ("%SWIFT_ROOT%\Toolchains\*") do (
  if exist "%%T\usr\bin\swiftc.exe" set "SWIFTC_FOUND=1"
)
if not defined SWIFTC_FOUND exit /b 1
set "SDK_FOUND="
for /d %%P in ("%SWIFT_ROOT%\Platforms\*") do (
  if exist "%%P\Windows.platform\Developer\SDKs\Windows.sdk\usr\lib\swift\windows\x86_64" set "SDK_FOUND=1"
)
if not defined SDK_FOUND exit /b 1

rem Keep the bundled LLVM tools off PATH and expose only Swift-facing commands.
mkdir "%PREFIX%\Scripts"
for %%T in (sourcekit-lsp swift swift-build swift-format swift-package swift-run swift-test swiftc) do (
  copy "%RECIPE_DIR%\swift-launcher.bat" "%PREFIX%\Scripts\%%T.bat"
  if errorlevel 1 exit /b 1
)

endlocal
