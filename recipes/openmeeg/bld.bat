cmake -G "NMake Makefiles" -DBLA_VENDOR=OpenBLAS -DENABLE_PYTHON=OFF -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_DOCUMENTATION=OFF %SRC_DIR%
if errorlevel 1 exit rem 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
