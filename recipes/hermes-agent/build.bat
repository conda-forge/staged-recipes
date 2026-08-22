@echo on
setlocal

@REM This skill's license forbids retaining or distributing it outside Anthropic services.
if exist "skills\productivity\powerpoint" rmdir /S /Q "skills\productivity\powerpoint"
if exist "skills\index-cache" rmdir /S /Q "skills\index-cache"

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || exit /b 1

@REM setuptools does not preserve these data-file trees in the generated wheel.
if not exist "%PREFIX%\skills" mkdir "%PREFIX%\skills" || exit /b 1
if not exist "%PREFIX%\optional-skills" mkdir "%PREFIX%\optional-skills" || exit /b 1
xcopy /E /H /I /Y skills "%PREFIX%\skills" || exit /b 1
xcopy /E /H /I /Y optional-skills "%PREFIX%\optional-skills" || exit /b 1
