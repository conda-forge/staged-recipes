unzip -d mklist -o mklist1_6.zip
if errorlevel 1 exit 1

cd mklist
xcopy include\* . /s /i /y
if errorlevel 1 exit 1

make
xcopy mklist.exe %LIBRARY_PREFIX%\bin\ /y
if errorlevel 1 exit 1

