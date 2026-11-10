@echo on

:: PlotJuggler's install rules; Qt, Python, the plugin SDK and every library come
:: from the environment.
cmake -G Ninja -S . -B build %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DPJ_SYSTEM_QWT=ON ^
  -DPJ_BUILD_TESTS=OFF ^
  -DPJ_BUILD_DEMOS=OFF ^
  -DPJ_DEBUG_INFO=none ^
  -DPJ_VERSION=%PKG_VERSION% ^
  -DPJ_INSTALLATION=conda ^
  -DPJ_QT_MIN_VERSION=6.11 ^
  -DPJ_SYSTEM_ADS=ON ^
  -DPJ_SYSTEM_NANOCDR=ON
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
