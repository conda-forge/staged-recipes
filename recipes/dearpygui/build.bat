mkdir cmake-build-local
cd cmake-build-local

cmake .. -G "Ninja" ^
    -DMVDIST_ONLY=True ^
    -DMVDPG_VERSION="%PKG_VERSION%" ^
    -DMV_PY_VERSION="%PY_VER%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    %CMAKE_ARGS%
if errorlevel 1 exit 1

cd ..
cmake --build cmake-build-local --config Release
if errorlevel 1 exit 1

REM Copy the built shared library into the Python package directory
copy cmake-build-local\DearPyGui\_dearpygui* DearPyGui\
if errorlevel 1 exit 1

REM Patch setup.py to skip its own CMake build since we already built above
"%PYTHON%" -c "p=__import__('pathlib').Path('setup.py');p.write_text(p.read_text().replace(\"self.run_command('dpg_build')\",\"pass\"))"
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . --no-deps --no-build-isolation
if errorlevel 1 exit 1
