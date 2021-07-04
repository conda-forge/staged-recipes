:: Visual Studio 2008 doesn't have stdint.h
if "%VisualStudioVersion%" == "" (
  mkdir include
  copy %RECIPE_DIR%\msvc2008-stdint\stdint.h %BUILD_PREFIX%\Library\include\stdint.h
  if errorlevel 1 exit 1
)

"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
