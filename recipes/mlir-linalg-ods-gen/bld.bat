@echo on
mkdir build
cd build

cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DLLVM_BUILD_TOOLS=ON ^
  -DLLVM_BUILD_UTILS=ON ^
  ..\mlir
if errorlevel 1 exit 1

ninja mlir-linalg-ods-gen mlir-linalg-ods-yaml-gen
if errorlevel 1 exit 1

copy bin\mlir-linalg-ods-gen.exe %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
copy bin\mlir-linalg-ods-yaml-gen.exe %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
