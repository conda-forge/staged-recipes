@echo on

set WAMR_PROFILE=%~1
if "%WAMR_PROFILE%"=="" (
  echo WAMR profile is required
  exit /b 1
)

if "%WAMR_PROFILE%"=="compiler" goto compiler

set FAST_INTERP=1
set BUILD_AOT=0
set BUILD_JIT=0
set LLVM_DIR_ARG=
if "%WAMR_PROFILE%"=="aot" set BUILD_AOT=1
if "%WAMR_PROFILE%"=="jit" (
  set FAST_INTERP=0
  set BUILD_AOT=1
  set BUILD_JIT=1
  set LLVM_CONFIG_DIR=%BUILD_PREFIX%\freecad-wamr-llvm-config
  if not exist "%LLVM_CONFIG_DIR%" mkdir "%LLVM_CONFIG_DIR%"
  > "%LLVM_CONFIG_DIR%\LLVMConfig.cmake" echo include("%LIBRARY_PREFIX%/lib/cmake/llvm/LLVMConfig.cmake")
  >> "%LLVM_CONFIG_DIR%\LLVMConfig.cmake" echo set(LLVM_AVAILABLE_LIBS LLVM)
  > "%LLVM_CONFIG_DIR%\LLVMConfigVersion.cmake" echo set(PACKAGE_VERSION "0")
  set LLVM_DIR_ARG=-DLLVM_DIR=%LLVM_CONFIG_DIR%
)

cmake -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DWAMR_BUILD_INTERP=1 ^
  -DWAMR_BUILD_FAST_INTERP=%FAST_INTERP% ^
  -DWAMR_BUILD_AOT=%BUILD_AOT% ^
  -DWAMR_BUILD_JIT=%BUILD_JIT% ^
  -DWAMR_BUILD_FAST_JIT=0 ^
  -DWAMR_BUILD_LIBC_BUILTIN=1 ^
  -DWAMR_BUILD_LIBC_WASI=0 ^
  -DWAMR_BUILD_MULTI_MODULE=0 ^
  -DWAMR_BUILD_BULK_MEMORY=1 ^
  -DWAMR_BUILD_SHARED_MEMORY=0 ^
  -DWAMR_BUILD_THREAD_MGR=0 ^
  -DWAMR_BUILD_LIB_PTHREAD=0 ^
  -DWAMR_BUILD_LIB_WASI_THREADS=0 ^
  -DWAMR_BUILD_MINI_LOADER=0 ^
  -DWAMR_BUILD_SIMD=1 ^
  -DWAMR_BUILD_REF_TYPES=1 ^
  -DWAMR_BUILD_MEMORY64=0 ^
  -DWAMR_BUILD_MULTI_MEMORY=0 ^
  -DWAMR_BUILD_INSTRUCTION_METERING=1 ^
  %LLVM_DIR_ARG%
if errorlevel 1 exit /b 1
goto build

:compiler
cmake -S wamr-compiler -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DWAMR_BUILD_WITH_CUSTOM_LLVM=1 ^
  -DLLVM_DIR=%LIBRARY_PREFIX%\lib\cmake\llvm
if errorlevel 1 exit /b 1

:build
cmake --build build --target install --parallel
if errorlevel 1 exit /b 1
