@echo on

md "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build
set TBBROOT=%LIBRARY_PREFIX%
cmake -GNinja %CMAKE_ARGS% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DDNNL_CPU_RUNTIME=TBB ^
  -DDNNL_GPU_RUNTIME=NONE ^
  ..
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
ninja test
if errorlevel 1 exit 1
popd
