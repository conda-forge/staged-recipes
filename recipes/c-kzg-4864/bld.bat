
%PYTHON% %RECIPE_DIR%\helpers\generate_static_libpython.py

%PYTHON% -m pip wheel -w wheels . ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all:
if errorlevel 1 exit 1
