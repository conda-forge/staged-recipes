mkdir tmp-build
if errorlevel 1 exit 1
cd tmp-build
if errorlevel 1 exit 1
cmake ..\pythonfmu\pythonfmu-export --verbose -DPython3_EXECUTABLE:FILEPATH="%PYTHON%" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1
cmake --build . --config Release
if errorlevel 1 exit 1
cd ..
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
