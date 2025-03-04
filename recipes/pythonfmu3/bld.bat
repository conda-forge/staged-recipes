
mkdir build

cmake -S pythonfmu3/pythonfmu-export -B build -DPython3_EXECUTABLE:FILEPATH=%PYTHON%

if errorlevel 1 exit 1

cmake --build build --config Release

if errorlevel 1 exit 1


%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
