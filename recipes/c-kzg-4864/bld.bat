
%PYTHON% %RECIPE_DIR%\helpers\generate_static_libpython.py

%PYTHON% -m pip wheel -w %SRC_DIR%\wheels . ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all:
if errorlevel 1 exit 1

dir %SRC_DIR%\wheels
