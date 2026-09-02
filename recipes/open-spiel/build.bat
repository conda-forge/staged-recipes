@echo on

python "%RECIPE_DIR%\rewrite_system_includes.py"
if errorlevel 1 exit 1

set "BUILD_TYPE=Release"
set "CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%"
set "OPEN_SPIEL_ENABLE_JAX=OFF"
set "OPEN_SPIEL_ENABLE_PYTORCH=OFF"
set "OPEN_SPIEL_BUILDING_WHEEL=ON"

"%PYTHON%" -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1
