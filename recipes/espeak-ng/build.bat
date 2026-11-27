@echo on

:: path_home (the espeak-ng-data path) is a fixed-size buffer; make room for long prefixes
set "CFLAGS=%CFLAGS% -DN_PATH_HOME=1024"

cmake -S . -B build %CMAKE_ARGS% -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DBUILD_TESTING=OFF ^
  -DUSE_LIBPCAUDIO=OFF ^
  -DUSE_MBROLA=OFF ^
  -DESPEAK_BUILD_MANPAGES=OFF ^
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON ^
  "-DFETCHCONTENT_SOURCE_DIR_SONIC-GIT=%SRC_DIR%/sonic"
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
