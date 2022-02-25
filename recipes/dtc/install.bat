@echo on

if "%PKG_NAME%" == "dtc" (
     make install-bin PREFIX="%PREFIX%"
     if %ERRORLEVEL% neq 0 exit 1
)
if "%PKG_NAME%" == "pylibfdt" (
     make install-bin PREFIX="%PREFIX%"
     if %ERRORLEVEL% neq 0 exit 1
)
if "%PKG_NAME%" == "libfdt" (
     make install-lib install-includes PREFIX="%PREFIX%"
     if %ERRORLEVEL% neq 0 exit 1
)
