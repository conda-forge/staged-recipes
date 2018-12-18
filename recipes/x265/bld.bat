@echo on

@mkdir 12bit
@mkdir 10bit
@mkdir 8bit


@cd 12bit

cmake -G "%CMAKE_GENERATOR%"                      ^
      -DCMAKE_BUILD_TYPE="Release"                ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
      -DHIGH_BIT_DEPTH=ON                         ^
      -DMAIN12=ON                                 ^
      -DEXPORT_C_API=OFF                          ^
      -DENABLE_SHARED=OFF                         ^
      -DENABLE_CLI=OFF                            ^
      ../source

if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

dir
dir Release
copy/y Release\x265-static.lib ..\8bit\x265-static-main12.lib

@cd ..\10bit

cmake -G "%CMAKE_GENERATOR%"                      ^
      -DCMAKE_BUILD_TYPE="Release"                ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
      -DHIGH_BIT_DEPTH=ON                         ^
      -DEXPORT_C_API=OFF                          ^
      -DENABLE_SHARED=OFF                         ^
      -DENABLE_CLI=OFF                            ^
      ../source

if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

copy/y Release\x265-static.lib ..\8bit\x265-static-main10.lib

@cd ..\8bit
if not exist x265-static-main10.lib (
  exit 1
)
if not exist x265-static-main12.lib (
  exit 1
)

cmake -G "%CMAKE_GENERATOR%"                      ^
      -DCMAKE_BUILD_TYPE="Release"                ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
      -DEXTRA_LIB="x265-static-main10.lib;x265-static-main12.lib" ^
      -DLINKED_10BIT=ON                           ^
      -DLINKED_12BIT=ON                           ^
      -DENABLE_SHARED=ON                          ^
      -DENABLE_STATIC=OFF                         ^
      -DENABLE_HDR10_PLUS=ON                      ^
      ../source

if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
