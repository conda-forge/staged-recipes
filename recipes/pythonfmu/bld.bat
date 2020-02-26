mkdir tmp-build
if errorlevel 1 exit 1
cd tmp-build
if errorlevel 1 exit 1
cmake  --debug-output -G "Ninja" ^
       -DPython3_EXECUTABLE:FILEPATH="%PYTHON%" ^
       -DCMAKE_BUILD_TYPE=Release ^
       ..\pythonfmu\pythonfmu-export
more .\CMakeFiles\CMakeOutput.log
if errorlevel 1 exit 1
REM cmake --build . --config Release --verbose
ninja install
if errorlevel 1 exit 1
cd ..
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
