rem # Common settings

set CPU_COUNT=%NUMBER_OF_PROCESSORS%
set PATH="%PATH%;%BUILD_PREFIX%/x86_64-conda-linux-gnu/lib;%BUILD_PREFIX/lib;%PREFIX/lib"
set INCLUDE="%INCLUDE%;%cd%/include;%BUILD_PREFIX/x86_64-conda-linux-gnu/include/c++/12.3.0;%BUILD_PREFIX%/x86_64-conda-linux-gnu/include/c++/12.3.0/x86_64-conda-linux-gnu;%BUILD_PREFIX%/x86_64-conda-linux-gnu/sysroot/usr/include;%BUILD_PREFIX%/include;%PREFIX%/include"
set CMAKE_EXTRA_PARAMS=""
set BUILD_CLANG="0"

rem # LLVM/Clang settings

set LLVM_DIR="%SRC_DIR%/llvm_project"
set LLVM_BUILD_DIR="%LLVM_DIR%/build"

IF /I "%backend%" == "repl" (
  set PATH="%PATH;%LLVM_BUILD_DIR%/lib;%LLVM_DIR%/lib"
  set INCLUDE="%INCLUDE%;%LLVM_BUILD_DIR%/tools/clang/include;%LLVM_BUILD_DIR%/include;%LLVM_DIR%/clang/include;%LLVM_DIR%/llvm/include"
  set BUILD_CLANG="1"
  set CMAKE_BUILD_CLANG_TARGETS="clang-repl"
)

rem ### Cling settings

if /I "%backend%" == "cling" (
  set CLING_DIR="%SRC_DIR%/cling"
  set CLING_BUILD_DIR="%LLVM_BUILD_DIR%"
  set INCLUDE="%INCLUDE%;%CLING_BUILD_DIR%/include;%CLING_DIR%/tools/cling/include"
  set CMAKE_EXTRA_PARAMS="-DLLVM_EXTERNAL_PROJECTS=cling -DLLVM_EXTERNAL_CLING_SOURCE_DIR=%CLING_DIR%"
  set BUILD_CLANG="1"
  set CMAKE_BUILD_CLANG_TARGETS="cling"
)

rem ### LLVM/Clang (with optional Cling) build

if "%BUILD_CLANG%" == "1" (
  pushd llvm-project
  cd llvm-project
  mkdir build
  cd build
  rem # FIXME: Does  -DLLVM_TARGETS_TO_BUILD="host;NVPTX" make sense for conda?
  cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"            ^
    -DCMAKE_BUILD_TYPE=Release                   ^
    -DCMAKE_LIBRARY_PATH="%PREFIX%"              ^
    -DLLVM_DEFAULT_TARGET_TRIPLE=%CONDA_TOOLCHAIN_HOST% ^
    -DLLVM_HOST_TRIPLE=%CONDA_TOOLCHAIN_HOST%    ^
    -DLLVM_UTILS_INSTALL_DIR=libexec/llvm        ^
    -DLLVM_ENABLE_PROJECTS="clang"               ^
    -DLLVM_TARGETS_TO_BUILD="host;NVPTX"         ^
    -DLLVM_ENABLE_ASSERTIONS=ON                  ^
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF           ^
    -DCLANG_ENABLE_ARCMT=OFF                     ^
    -DCLANG_ENABLE_BOOTSTRAP=OFF                 ^
    -DLLVM_ENABLE_TERMINFO=OFF                   ^
    %CMAKE_EXTRA_PARAMS% ^
    %CMAKE_ARGS% ^
    ../llvm

  ninja -j%CPU_COUNT% %CMAKE_BUILD_CLANG_TARGETS%
  if errorlevel 1 exit 1

  popd
)

rem ### Build CppInterOp next to cling and llvm-project.

pushd cppinterop
mkdir build
cd build

export CPPINTEROP_BUILD_DIR=%cd%
if /I "%backend%" == "cling" (
rem   # For some reason the folders are expanded to %SRC_DIR%/llvm-project/...
rem   # and we cannot use the LLVM_BUILD_DIR and other variables.
  cmake                                                    ^
    -G "Ninja" ^
    -DUSE_CLING=ON                                         ^
    -DUSE_REPL=OFF                                         ^
    -DCling_DIR=%SRC_DIR%/llvm-project/build/tools/cling/  ^
    -DLLVM_DIR=%SRC_DIR%/llvm-project/build/               ^
    -DBUILD_SHARED_LIBS=ON                                 ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%                        ^
    -DCPPINTEROP_ENABLE_TESTING=OFF                        ^
    %CMAKE_ARGS%                                           ^
    ..
  ninja -j%CPU_COUNT%
  if errorlevel 1 exit 1
) else (
  cmake ^
    -G "Ninja" ^
    -DUSE_CLING=OFF                           ^
    -DUSE_REPL=ON                             ^
    -DLLVM_DIR=%SRC_DIR%/llvm-project/build/  ^
    -DBUILD_SHARED_LIBS=ON                    ^
    -DCMAKE_INSTALL_PREFIX=%CPPINTEROP_DIR%   ^
    -DCPPINTEROP_ENABLE_TESTING=ON            ^
    %CMAKE_ARGS%                              ^
    ..
  ninja -j%CPU_COUNT% check-cppinterop
  if errorlevel 1 exit 1
)

ninja install
if errorlevel 1 exit 1

popd
