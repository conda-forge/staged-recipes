cd runtime\libpgmath

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

set PIP_NO_INDEX=
pip install lit

cmake ^
  -G"NMake Makefiles JOM" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  ..

jom -j%CPU_COUNT%
jom install
jom check-libpgmath
