mkdir build
cd build

cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DLLVM_BUILD_TOOLS=ON ^
  -DLLVM_BUILD_UTILS=ON ^
  ..\mlir

ninja mlir-linalg-ods-gen mlir-linalg-ods-yaml-gen
copy bin/mlir-linalg-ods-gen.exe bin/mlir-linalg-ods-yaml-gen.exe %LIBRARY_PREFIX%/bin
