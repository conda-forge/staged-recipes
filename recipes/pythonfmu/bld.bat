mkdir tmp-build
cd tmp-build
cmake ../pythonfmu/pythonfmu-export -DPython3_EXECUTABLE:FILEPATH="%PYTHON%" -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
cd ..

%PYTHON% -m pip install . -vv

if errorlevel 1 exit 1
