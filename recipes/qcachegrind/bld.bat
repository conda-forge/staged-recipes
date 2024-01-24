
mkdir build
cd build
if errorlevel 1 exit 1

qmake ..\qcg.pro
if errorlevel 1 exit 1

jom
if errorlevel 1 exit 1

for %%t in (cgview qcachegrind) do copy %%t\release\%%t.exe %LIBRARY_BIN%
if errorlevel 1 exit 1
