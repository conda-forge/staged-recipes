@echo on

mkdir build
cd build

cmake %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release ..
if %ERRORLEVEL% neq 0 exit 1

make -j
if %ERRORLEVEL% neq 0 exit 1

mkdir -p %PREFIX%\bin\
mv fulgor.exe %PREFIX%\bin\
if %ERRORLEVEL% neq 0 exit 1
