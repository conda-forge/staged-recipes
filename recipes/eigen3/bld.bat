@echo ON
setlocal enabledelayedexpansion

mkdir build
cd build
cmake -G "NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_BUILD_TYPE=Release -DEIGEN_SKIP_TESTS=ON ..
cmake --build . --target install --config Release
	