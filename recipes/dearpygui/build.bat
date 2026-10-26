REM Remove bundled ImGuiFileDialog.h so the system header (v0.6.7) is used.
REM The directory is kept in the include path for DearPyGui-specific CustomFont files.
del /f thirdparty\ImGuiFileDialog\ImGuiFileDialog.h

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

REM setup.py expects the .pyd in a Release\ subdirectory (Visual Studio layout)
REM but Ninja (single-config) puts it directly in cmake-build-local\DearPyGui\
mkdir cmake-build-local\DearPyGui\Release
copy cmake-build-local\DearPyGui\_dearpygui.pyd cmake-build-local\DearPyGui\Release\
if errorlevel 1 exit 1

REM Patch setup.py:
REM 1. Don't delete our pre-built cmake-build-local directory
REM 2. Skip the cmake subprocess calls but keep the shutil.copy that
REM    moves the built library into output\dearpygui\
"%PYTHON%" -c "import pathlib; p = pathlib.Path('setup.py'); t = p.read_text(); t = t.replace('shutil.rmtree(src_path + \"/cmake-build-local\")', 'pass'); t = t.replace(\"subprocess.check_call(''.join(command), shell=True)\", 'pass'); t = t.replace(\"subprocess.check_call(''.join(command), env=os.environ, shell=True)\", 'pass'); p.write_text(t)"
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . --no-deps --no-build-isolation
if errorlevel 1 exit 1
