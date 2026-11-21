@echo on
rem Usage: admin-install.bat PACKAGE.msi
rem Administratively installs %SRC_DIR%\layout\PACKAGE.msi, as extracted by
rem extract-burn.py, into %SWIFT_ADMIN%\<package name>. SWIFT_ADMIN is a short
rem path because the platform SDK contains filenames which exceed MAX_PATH
rem under rattler-build's work path.
setlocal EnableExtensions
rmdir /S /Q "%SWIFT_ADMIN%\%~n1" 2>nul
mkdir "%SWIFT_ADMIN%\%~n1"
start /wait "" msiexec.exe /a "%SRC_DIR%\layout\%~1" /qn /l*v "%SWIFT_ADMIN%\%~n1.log" TARGETDIR="%SWIFT_ADMIN%\%~n1" INSTALLROOT="%SWIFT_ADMIN%\%~n1"
if errorlevel 1 (
  type "%SWIFT_ADMIN%\%~n1.log"
  exit /b 1
)
endlocal
