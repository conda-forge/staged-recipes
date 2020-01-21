REM The 'official' supported way of building this software is with MSBuild as
REM the CMAKE_MAKE_PROGRAM; but the azure image for vs2017-win2016 is screwed
REM up (missing registry keys for VS2015), so we end up using Ninja instead. 

REM Ideally, cdk\protobuf should have been built automatically, but the
REM dependency on the thir party library is not specified correctly for the
REM Ninja generator. Hence we end up using two build commands.

for %%O in (ON OFF) DO ( 
   cmake -S. ^
     -Bbuild.%%O ^
     -GNinja ^
     -DBUILD_STATIC=%%O ^
     -DCMAKE_BUILD_TYPE=Release ^
     -DCMAKE_INSTALL_LIBDIR=lib ^
     -DWITH_SSL=%LIBRARY_PREFIX% ^
     -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
     -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
     -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
     REM -G"%CMAKE_GENERATOR%" ^
   if ERRORLEVEL 1 EXIT 1

   cmake --build build.%%O/cdk/protobuf
   cmake --build build.%%O --target install
   REM cmake --build build.%%O --target install
   REM cmake --build build.%%O --config Release --target install
   if ERRORLEVEL 1 EXIT 1
)

move %LIBRARY_PREFIX%\INFO_SRC %LIBRARY_PREFIX%\%PKG_NAME%_INFO_SRC
move %LIBRARY_PREFIX%\INFO_BIN %LIBRARY_PREFIX%\%PKG_NAME%_INFO_BIN
