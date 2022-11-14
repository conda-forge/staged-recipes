echo ON
setlocal enabledelayedexpansion

mkdir -p openvino-build

cmake ${CMAKE_ARGS}                                                          ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                                ^
    -DCMAKE_BUILD_TYPE=Release                                               ^
    -DOPENVINO_EXTRA_MODULES="%SRC_DIR%/openvino_contrib/modules/arm_plugin" ^
    -DENABLE_INTEL_GNA=OFF                                                   ^
    -DENABLE_INTEL_GPU=OFF                                                   ^
    -DENABLE_INTEL_MYRIAD_COMMON=OFF                                         ^
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache                                     ^
    -DCMAKE_C_COMPILER_LAUNCHER=ccache                                       ^
    -DENABLE_SYSTEM_TBB=ON                                                   ^
    -DENABLE_SYSTEM_PUGIXML=ON                                               ^
    -DENABLE_SYSTEM_PROTOBUF=ON                                              ^
    -DENABLE_COMPILE_TOOL=OFF                                                ^
    -DENABLE_PYTHON=OFF                                                      ^
    -DENABLE_CPPLINT=OFF                                                     ^
    -DENABLE_CLANG_FORMAT=OFF                                                ^
    -DENABLE_NCC_STYLE=OFF                                                   ^
    -DENABLE_TEMPLATE=OFF                                                    ^
    -DENABLE_REQUIREMENTS_INSTALL=OFF                                        ^
    -DENABLE_SAMPLES=OFF                                                     ^
    -DENABLE_DATA=OFF                                                        ^
    -DCPACK_GENERATOR=CONDA-FORGE                                            ^
    -DENABLE_WHEEL=OFF                                                       ^
    -G Ninja                                                                 ^
    -S "%SRC_DIR%/openvino_sources"                                          ^
    -B "%SRC_DIR%/openvino-build"
if errorlevel 1 exit 1

cmake --build "%SRC_DIR%/openvino-build" --config Release --parallel %CPU_COUNT% --verbose
if errorlevel 1 exit 1

exit 0
