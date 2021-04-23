mkdir %PREFIX%\bin

CD voro++
make
COPY src\voro++.exe %PREFIX%\bin\voro++.exe
CD ..
