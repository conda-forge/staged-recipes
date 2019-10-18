setlocal EnableDelayedExpansion

mkdir build
cd build

llvm-config
llvm-config --bindir
llvm-config

:: Configure
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DLLVM_VERSION_EXPLICIT="9.0.0" ^
      -DLIBCLANG_LIBRARY="%LIBRARY_BIN%\libclang.dll" ^
      -DLIBCLANG_INCLUDE_DIR="%LIBRARY_INC%" ^
      -DCLANG_BINARY="%LIBRARY_BIN%\clang.exe" ^
      ..
if errorlevel 1 exit 1

:: Build
nmake
if errorlevel 1 exit 1

:: Install
nmake install
