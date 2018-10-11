mkdir build
cd build

REM This is a fix for a CMake bug where it crashes because of the "/GL" flag
REM See: https://gitlab.kitware.com/cmake/cmake/issues/16282
@echo CXXFLAGS=%CXXFLAGS%
@echo CFLAGS=%CFLAGS%
set CXXFLAGS=%CXXFLAGS:-GL=%
set CFLAGS=%CFLAGS:-GL=%
@echo After removing -GL flag because of CMake bug:
@echo CXXFLAGS=%CXXFLAGS%
@echo CFLAGS=%CFLAGS%

cmake -G Ninja ^
      -DBUILD_ALL=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INCLUDE_PATH="%LIBRARY_INC%" ^
      -DBOOST_INCLUDE_DIR="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      "-DTHIRDPARTY_COMMON_ARGS=-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON" ^
      ..
cmake --build . --config Release --target install
