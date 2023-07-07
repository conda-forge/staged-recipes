MKDIR build\windows
CD build\windows

cmake ^
    -G "NMake Makefiles"                     ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%     ^
    -DCMAKE_BUILD_TYPE=Release               ^
    ..\..

cmake --build . --config Release

copy libmetis\metis.lib %LIBRARY_LIB%
copy programs\cmpfillin.exe %LIBRARY_BIN%
copy programs\gpmetis.exe %LIBRARY_BIN%
copy programs\graphchk.exe %LIBRARY_BIN%
copy programs\m2gmetis.exe %LIBRARY_BIN%
copy programs\ndmetis.exe %LIBRARY_BIN%
copy programs\mpmetis.exe %LIBRARY_BIN%
copy ..\..\include\metis.h %LIBRARY_INC%

CD programs
mpmetis.exe ..\..\..\graphs\metis.mesh 10
if errorlevel 1 exit 1
gpmetis.exe ..\..\..\graphs\mdual.graph 10
if errorlevel 1 exit 1
ndmetis.exe ..\..\..\graphs\mdual.graph
if errorlevel 1 exit 1
gpmetis.exe ..\..\..\graphs\test.mgraph 10
if errorlevel 1 exit 1
m2gmetis.exe ..\..\..\graphs\metis.mesh 10
if errorlevel 1 exit 1
