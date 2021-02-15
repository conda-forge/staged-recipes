set getopt_build_mode=Release
set getopt_build_arch=x%ARCH%

msbuild /p:Configuration=%getopt_build_mode%
if errorlevel 1 exit 1

cp %getopt_build_arch%\%getopt_build_mode%\getopt.dll %LIBRARY_BIN%
cp %getopt_build_arch%\%getopt_build_mode%\getopt.lib %LIBRARY_LIB%
cp %SRC_DIR%\getopt.h                                 %LIBRARY_INC%
