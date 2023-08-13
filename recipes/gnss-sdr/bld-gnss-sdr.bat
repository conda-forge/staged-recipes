setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir forgebuild
if errorlevel 1 exit 1
cd forgebuild
if errorlevel 1 exit 1

:: configure
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DENABLE_AD9361=ON ^
    -DENABLE_ARRAY=OFF ^
    -DENABLE_BENCHMARKS=ON ^
    -DENABLE_CUDA=OFF ^
    -DENABLE_FPGA=OFF ^
    -DENABLE_FLEXIBAND=OFF ^
    -DENABLE_FMCOMMS2=ON ^
    -DENABLE_GPERFTOOLS=OFF ^
    -DENABLE_GPROF=OFF ^
    -DENABLE_GNSS_SIM_INSTALL=OFF ^
    -DENABLE_INSTALL_TESTS=OFF ^
    -DENABLE_LIMESDR=OFF ^
    -DENABLE_OPENCL=OFF ^
    -DENABLE_OSMOSDR=ON ^
    -DENABLE_PACKAGING=ON ^
    -DENABLE_PLUTOSDR=ON ^
    -DENABLE_RAW_UDP=ON ^
    -DENABLE_SYSTEM_TESTING=OFF ^
    -DENABLE_SYSTEM_TESTING_EXTRA=OFF ^
    -DENABLE_UHD=ON ^
    -DENABLE_UNIT_TESTING=OFF ^
    -DENABLE_UNIT_TESTING_EXTRA=OFF ^
    -DENABLE_UNIT_TESTING_MINIMAL=ON ^
    -DENABLE_ZMQ=ON ^
    -DGFLAGS_ROOT="%LIBRARY_PREFIX%" ^
    -DGFlags_ROOT_DIR="%LIBRARY_PREFIX%" ^
    -DGLOG_INCLUDE_DIRS="%LIBRARY_INCLUDE%/glog" ^
    -DGLOG_LIBRARIES="%LIBRARY_LIB%\glog.lib" ^
    -DGLOG_ROOT="%LIBRARY_PREFIX%" ^
    -DGNSSSDR_INSTALL_DIR_DEF=%%CONDA_PREFIX%%/Library ^
    -DLIBAD9361_LIBRARIES="%LIBRARY_LIB%\libad9361.lib" ^
    -DLIBIIO_LIBRARIES="%LIBRARY_LIB%\libiio.lib" ^
    -DZEROMQ_LIBRARIES="%LIBRARY_LIB%\libzmq.lib" ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
