dir /S

copy /Y %RECIPE_DIR%\CMakeLists.txt launcher\CMakeLists.txt

mkdir launcher\x64
if errorlevel 1 exit /b 1

pushd launcher\x64

REM cmake -G Ninja -B. -S..
cmake -G "NMake Makefiles" -B. -S.. -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit /b 1

dir /S

REM cmake --build . --config Release
nmake
if errorlevel 1 exit /b 1

ren build Release
if errorlevel 1 exit /b 1

popd

dir /S

"%PYTHON%" -m pip install --no-deps --ignore-installed .
if errorlevel 1 exit /b 1
