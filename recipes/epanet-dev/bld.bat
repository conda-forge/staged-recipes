mkdir build
cd build
cmake .. -G "NMake Makefiles"

cmake --build . --config Release
if errorlevel 1 exit 1

copy bin\epanet3.dll %LIBRARY_BIN%\epanet3.dll
if errorlevel 1 exit 1

copy bin\run-epanet3.exe %LIBRARY_BIN%\run-epanet3.exe
if errorlevel 1 exit 1

copy bin\epanet3.lib %LIBRARY_LIB%\epanet3.lib
if errorlevel 1 exit 1
