@echo on
setlocal EnableDelayedExpansion

REM Fortran pots are off on Windows for now: the kernels build with flang,
REM whose llvm-ar writes GNU-format archives that MSVC's link.exe rejects
REM (LNK1107). The flang/MSVC kernel leg is a separate phase upstream.
meson setup builddir ^
  --prefix="%LIBRARY_PREFIX%" ^
  --libdir=lib ^
  --buildtype=release ^
  -Dwith_rpc=true ^
  -Dwith_fortran_pots=disabled ^
  -Dwith_eigen=true ^
  -Dpure_lib=false ^
  -Dwith_cache=false ^
  -Dwith_tests=false ^
  -Dwith_examples=false
if errorlevel 1 exit 1

meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

meson install -C builddir
if errorlevel 1 exit 1
