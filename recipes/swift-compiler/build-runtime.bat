@echo on
setlocal EnableExtensions

for %%D in ("%SRC_DIR%") do set "SWIFT_ADMIN=%%~dD\swift-admin"
python "%RECIPE_DIR%\extract-burn.py" "%SRC_DIR%\swift-installer.exe" "%SRC_DIR%\layout" rtl.amd64.msi
if errorlevel 1 exit /b 1
call "%RECIPE_DIR%\admin-install.bat" rtl.amd64.msi
if errorlevel 1 exit /b 1

rem The runtime MSI installs its files directly into TARGETDIR. Library\bin is
rem on conda's standard Windows PATH. The bundled MSVC runtime is provided by
rem conda-forge's vc14_runtime package instead.
if not exist "%SWIFT_ADMIN%\rtl.amd64\swiftCore.dll" exit /b 1
del /F /Q "%SWIFT_ADMIN%\rtl.amd64\concrt140.dll" "%SWIFT_ADMIN%\rtl.amd64\msvcp140*.dll" "%SWIFT_ADMIN%\rtl.amd64\vccorlib140.dll" "%SWIFT_ADMIN%\rtl.amd64\vcruntime140*.dll"
mkdir "%PREFIX%\Library\bin"
xcopy /I /Y "%SWIFT_ADMIN%\rtl.amd64\*" "%PREFIX%\Library\bin\"
if errorlevel 1 exit /b 1
rmdir /S /Q "%SWIFT_ADMIN%"

endlocal
