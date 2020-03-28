REM dir /S

REM conda info
REM conda list
REM conda env list

REM "%PYTHON%" --version

REM copy /Y %RECIPE_DIR%\CMakeLists.txt launcher\CMakeLists.txt

mkdir launcher\x64
if errorlevel 1 exit /b 1

pushd launcher\x64

REM default python is from the activate conda environment which is not the build environment; specify python to cmake
cmake -G "NMake Makefiles" -B. -S.. -DCMAKE_BUILD_TYPE:STRING=Release -DPython3_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit /b 1

REM dir /S

REM cmake --build . --config Release
cmake --build . --config Release
if errorlevel 1 exit /b 1

ren build Release
if errorlevel 1 exit /b 1

popd

REM dir /S

"%PYTHON%" -m pip install --no-deps --ignore-installed .
if errorlevel 1 exit /b 1
