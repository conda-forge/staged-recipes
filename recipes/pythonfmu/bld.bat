dir .
mkdir tmp-build
if errorlevel 1 exit 1
dir .
cd tmp-build
if errorlevel 1 exit 1
dir .
cmake ..\pythonfmu\pythonfmu-export --debug-output -DPython3_EXECUTABLE:FILEPATH="%PYTHON%" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1
cmake --build . --config Release --verbose
if errorlevel 1 exit 1
cd ..
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
