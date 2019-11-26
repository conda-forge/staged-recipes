setlocal EnableDelayedExpansion

cd build

cmake -DCMAKE_INSTALL_LOCAL_ONLY=1 -P cmake_install.cmake
if errorlevel 1 exit 1
cmake -P docs/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gnuradio-runtime/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-analog/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-audio/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-blocks/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-channels/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-digital/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-dtv/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-fec/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-fft/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-filter/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-trellis/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-utils/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-video-sdl/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-vocoder/cmake_install.cmake
if errorlevel 1 exit 1
cmake -P gr-wavelet/cmake_install.cmake
if errorlevel 1 exit 1
