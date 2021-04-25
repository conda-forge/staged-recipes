mkdir %PREFIX%\bin

REM list environment variables
SET

make
COPY src\voro++.exe %PREFIX%\bin\voro++.exe
