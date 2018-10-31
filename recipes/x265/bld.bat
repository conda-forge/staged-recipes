@mkdir 12bit
@mkdir 10bit
@mkdir 8bit


@cd 12bit

cmake -G "Visual Studio 15 Win64"                  \
      -DCMAKE_INSTALL_PREFIX=%PREFIX%              \
      -DHIGH_BIT_DEPTH=ON                          \
      -DMAIN12=ON                                  \
      -DEXPORT_C_API=OFF                           \
      -DENABLE_SHARED=OFF                          \
      -DENABLE_CLI=OFF                             \
      ../source


if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
  copy/y Release\x265-static.lib ..\8bit\x265-static-main12.lib
)

@cd ..\10bit

cmake -G "Visual Studio 15 Win64"                 \
      -DCMAKE_INSTALL_PREFIX=%PREFIX%              \
      -DHIGH_BIT_DEPTH=ON                         \
      -DEXPORT_C_API=OFF                          \
      -DENABLE_SHARED=OFF                         \
      -DENABLE_CLI=OFF                            \
      ../source


if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
  copy/y Release\x265-static.lib ..\8bit\x265-static-main10.lib
)

@cd ..\8bit
if not exist x265-static-main10.lib (
  exit 1
)
if not exist x265-static-main12.lib (
  exit 1
)

cmake -G "Visual Studio 15 Win64"                \
      -DCMAKE_INSTALL_PREFIX=%PREFIX%              \
      -DEXTRA_LIB="x265-static-main10.lib;x265-static-main12.lib" \
      -DLINKED_10BIT=ON                          \
      -DLINKED_12BIT=ON                          \
      ../source

if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
  :: combine static libraries (ignore warnings caused by winxp.cpp hacks)
  move Release\x265-static.lib x265-static-main.lib
  LIB.EXE /ignore:4006 /ignore:4221 /OUT:Release\x265-static.lib x265-static-main.lib x265-static-main10.lib x265-static-main12.lib
)
