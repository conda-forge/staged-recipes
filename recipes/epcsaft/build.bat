@echo on
call "%RECIPE_DIR%\build-env.bat"
"%PYTHON%" "%RECIPE_DIR%\build-jobs.py" bindings-ninja > jobs.txt
if errorlevel 1 exit /b 1
set JOBS=
set /p JOBS=<jobs.txt
if not defined JOBS exit /b 1
"%PYTHON%" -m pip install ./engine -vv --no-deps --no-build-isolation "--config-settings=build-dir=%SRC_DIR%\engine\build-bindings" --config-settings=setup-args=--wrap-mode=nodownload --config-settings=setup-args=-Depcsaft_build=bindings --config-settings=compile-args=-j%JOBS%
if errorlevel 1 exit /b 1
for %%P in (feos-gross-sadowski-2001 feos-gross-sadowski-2002) do (
  xcopy /e /i /y /q "%SRC_DIR%\data\packets\%%P\1" "%SP_DIR%\epcsaft\data\packets\%%P\1"
  if errorlevel 1 exit /b 1
)
copy "%LIBRARY_PREFIX%\bin\epcsaft_ipopt_31420.dll" "%SP_DIR%\epcsaft\"
if errorlevel 1 exit /b 1
"%PYTHON%" "%RECIPE_DIR%\licenses.py"
if errorlevel 1 exit /b 1
