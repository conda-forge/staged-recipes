@echo on

:: simple install prep
::   copy all impactx*.exe and impactx*.dll files
if not exist %LIBRARY_PREFIX%\bin md %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1

:: configure
cmake ^
    -S %SRC_DIR% -B build                 ^
    %CMAKE_ARGS%                          ^
    -G "Ninja"                            ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     ^
    -DCMAKE_C_COMPILER=clang-cl           ^
    -DCMAKE_CXX_COMPILER=clang-cl         ^
    -DCMAKE_LINKER=lld-link               ^
    -DCMAKE_NM=llvm-nm                    ^
    -DCMAKE_VERBOSE_MAKEFILE=ON           ^
    -DHiPACE_amrex_branch=23.02          ^
    -DHiPACE_openpmd_internal=OFF  ^
    -DHiPACE_COMPUTE=NOACC  ^
    -DHiPACE_MPI=OFF
if errorlevel 1 exit 1

:: build
cmake --build build --config RelWithDebInfo --parallel 2
if errorlevel 1 exit 1

:: test
ctest --test-dir build --build-config RelWithDebInfo --output-on-failure
if errorlevel 1 exit 1

:: install
cmake --build build --config RelWithDebInfo --target install
if errorlevel 1 exit 1
