@echo on
@setlocal EnableDelayedExpansion

cd /d "%SRC_DIR%\python" || goto :error

:: Let the activated conda-forge toolchain choose the Windows generator.
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || goto :error

echo build.bat: OK
goto :eof

:error
echo Failed with error #%errorlevel%.
exit /b 1
