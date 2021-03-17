@echo on

md "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build
set TBBROOT=%LIBRARY_PREFIX%
cmake -GNinja ^
  -DDNNL_CPU_RUNTIME=TBB ^
  -DDNNL_GPU_RUNTIME=NONE ^
  ..
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
ninja test
if errorlevel 1 exit 1
popd
