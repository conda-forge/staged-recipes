@echo on
setlocal EnableExtensions

rem Install only the native no-assert compiler, command-line tools, runtime, and
rem Windows SDK into the conda prefix. Avoid IDE, debugger, Python, Android,
rem and non-native SDK payloads.
start /wait "" "%SRC_DIR%\swift-installer.exe" /quiet /norestart InstallRoot="%PREFIX%" OptionsInstallAssertsToolchain=0 OptionsInstallNoAssertsToolchain=1 OptionsInstallCLI=1 OptionsInstallDBG=0 OptionsInstallPy=0 OptionsInstallIDE=0 OptionsInstallAndroidPlatform=0 OptionsInstallWindowsPlatform=1 OptionsInstallWindowsSDKX86=0 OptionsInstallWindowsRedistX86=0 OptionsInstallWindowsSDKAMD64=1 OptionsInstallWindowsRedistAMD64=1 OptionsInstallWindowsSDKARM64=0 OptionsInstallWindowsRedistARM64=0
if errorlevel 3011 exit /b %errorlevel%
if errorlevel 1 if not errorlevel 3010 exit /b %errorlevel%

if not exist "%PREFIX%\Toolchains\*\usr\bin\swiftc.exe" exit /b 1

mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\activate-swift.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\deactivate-swift.bat"
copy "%RECIPE_DIR%\LICENSE.txt" "%SRC_DIR%\LICENSE.txt"

endlocal
