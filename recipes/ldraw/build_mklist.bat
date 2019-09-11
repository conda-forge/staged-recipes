unzip -d mklist -o mklist1_6.zip

cd mklist
xcopy include\* . /s /i /y

make
xcopy mklist.exe %LIBRARY_PREFIX%\bin\ /y
