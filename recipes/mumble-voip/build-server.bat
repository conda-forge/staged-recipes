@echo off
:: Build script for mumble-server on Windows
:: See: https://github.com/mumble-voip/mumble/blob/master/docs/dev/build-instructions/build_windows.md
setlocal enabledelayedexpansion

cd /d "%SRC_DIR%\src\mumble"

:: Copy CMake config files provided alongside the recipe
copy "%SRC_DIR%\cmake-config\cmake_system_libs.cmake" .
copy "%SRC_DIR%\cmake-config\conda_toolchain.cmake" .

cmake -B build ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_STANDARD=20 ^
    -DCMAKE_CXX_STANDARD_REQUIRED=ON ^
    -Doverlay=OFF ^
    -Dzeroconf=OFF ^
    -Dice=OFF ^
    -Dclient=OFF ^
    -Dserver=ON ^
    -DTRACY_ENABLE=OFF ^
    "-DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%" ^
    "-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    "-DCMAKE_INSTALL_LIBDIR=%LIBRARY_PREFIX%\lib" ^
    "-DCMAKE_INSTALL_BINDIR=%LIBRARY_PREFIX%\bin" ^
    "-DCMAKE_INSTALL_INCLUDEDIR=%LIBRARY_PREFIX%\include" ^
    -DMUMBLE_INSTALL_LIBDIR=lib/mumble ^
    -DMUMBLE_INSTALL_PLUGINDIR=lib/mumble/plugins ^
    "-DCMAKE_CXX_FLAGS=/EHsc /DWIN32 /wd4996" ^
    "-DCMAKE_C_FLAGS=/std:c11 /EHsc /DWIN32 /wd4996" ^
    "-DCMAKE_CXX_FLAGS_RELEASE=/MD /O2 /DNDEBUG" ^
    "-DCMAKE_C_FLAGS_RELEASE=/MD /O2 /DNDEBUG" ^
    "-DCMAKE_EXE_LINKER_FLAGS=/DEFAULTLIB:ws2_32.lib /DEFAULTLIB:crypt32.lib" ^
    "-DQt5_DIR=%LIBRARY_PREFIX%\lib\cmake\Qt5" ^
    "-DOpus_ROOT=%LIBRARY_PREFIX%" ^
    "-DOgg_ROOT=%LIBRARY_PREFIX%" ^
    "-DSndFile_ROOT=%LIBRARY_PREFIX%" ^
    "-DSpeexDSP_ROOT=%LIBRARY_PREFIX%" ^
    "-DProtobuf_ROOT=%LIBRARY_PREFIX%" ^
    "-DProtobuf_DIR=%LIBRARY_PREFIX%\lib\cmake\protobuf" ^
    "-DSOCI_ROOT=%LIBRARY_PREFIX%" ^
    "-DMinhook_ROOT=%LIBRARY_PREFIX%" ^
    --toolchain conda_toolchain.cmake ^
    -Dbundled-json=OFF ^
    -Dbundled-spdlog=OFF ^
    -Dbundled-utf8cpp=OFF ^
    -Dbundled-opus=OFF ^
    -Dbundled-ogg=OFF ^
    -Dbundled-sndfile=OFF ^
    -Dbundled-flac=OFF ^
    -Dbundled-vorbis=OFF ^
    -Dbundled-speex=OFF ^
    -Dbundled-tracy=OFF ^
    -Dbundled-soci=OFF ^
    -Dbundled-gsl=OFF ^
    -Dbundled-minhook=OFF ^
    -Dbundled-SPSCQueue=OFF
if errorlevel 1 exit 1

cmake --build build -j %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

:: Install license files
mkdir "%PREFIX%\share\licenses\mumble-server"
copy "%SRC_DIR%\src\mumble\LICENSE" "%PREFIX%\share\licenses\mumble-server\LICENSE"
if exist "%SRC_DIR%\src\mumble\3rdPartyLicenses" (
    xcopy /s /e /i "%SRC_DIR%\src\mumble\3rdPartyLicenses" "%PREFIX%\share\licenses\mumble-server\3rdPartyLicenses"
)
