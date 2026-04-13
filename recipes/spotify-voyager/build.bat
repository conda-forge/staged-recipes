@echo on
@setlocal EnableDelayedExpansion

cd /d "%SRC_DIR%\python" || goto :error

:: build
set "CMAKE_GENERATOR=Ninja"
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || goto :error

echo build.bat: OK
goto :eof

:error
echo Failed with error #%errorlevel%.
exit /b 1
