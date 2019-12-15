
cmake -G"NMake Makefiles JOM" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  .
if errorlevel 1 exit 1

jom -j%CPU_COUNT%
if errorlevel 1 exit 1

jom -j%CPU_COUNT% install
if errorlevel 1 exit 1
