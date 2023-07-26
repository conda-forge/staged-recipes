@echo on

:: simple install prep
::   copy all hipace*.exe files
if not exist %LIBRARY_PREFIX%\bin md %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1

:: configure
cmake ^
    -S %SRC_DIR% -B build          ^
    %CMAKE_ARGS%                   ^
    -G "Ninja"                     ^
    -DAMReX_INSTALL=OFF            ^
    -DCMAKE_BUILD_TYPE=Release     ^
    -DCMAKE_C_COMPILER=clang-cl    ^
    -DCMAKE_CXX_COMPILER=clang-cl  ^
    -DCMAKE_LINKER=lld-link        ^
    -DCMAKE_NM=llvm-nm             ^
    -DCMAKE_VERBOSE_MAKEFILE=ON    ^
    -DHiPACE_amrex_branch=23.07    ^
    -DHiPACE_openpmd_internal=OFF  ^
    -DHiPACE_COMPUTE=NOACC         ^
    -DHiPACE_MPI=OFF
if errorlevel 1 exit 1

:: build
cmake --build build --config Release --parallel 2
if errorlevel 1 exit 1

:: test -> deferred to test.bat

:: install
::cmake --build build --config Release --target install
::if errorlevel 1 exit 1
for /r "build\bin" %%f in (*.exe) do (
    echo %%~nf
    dir
    copy build\bin\%%~nf.exe %LIBRARY_PREFIX%\bin\
    if errorlevel 1 exit 1
)
