mkdir build
cd build

cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DLLVM_USE_INTEL_JITEVENTS=1 ^
  -DLLVM_BUILD_TOOLS=ON ^
  -DLLVM_BUILD_UTILS=ON ^
  -DMLIR_ENABLE_BINDINGS_PYTHON=ON ^
  -DPython3_EXECUTABLE="%PYTHON%" ^
  ..\mlir

if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

ninja install
if not exist "%SP_DIR%" mkdir "%SP_DIR%"
move "%PREFIX%"\Library\python_packages\mlir_core\mlir "%SP_DIR%"\

if exist "%PREFIX%"\Library\python_packages rmdir /s /q "%PREFIX%"\Library\python_packages
if exist "%PREFIX%"\Library\src rmdir /s /q "%PREFIX%"\Library\src
