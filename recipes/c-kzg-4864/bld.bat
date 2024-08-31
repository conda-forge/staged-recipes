
%PYTHON% %RECIPE_DIR%\helpers\generate_static_libpython.py

%PYTHON% -m pip install . ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all: ^
  --prefix "%PREFIX%"
if errorlevel 1 exit 1
