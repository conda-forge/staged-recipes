@echo on
setlocal EnableDelayedExpansion

REM Flang emits COFF objects that MSVC link.exe accepts, but flang's
REM llvm-ar wraps them in GNU archives (LNK1107). Force MSVC lib.exe via
REM AR and the meson native file (same as upstream win-flang-msvc.ini).
set "AR=lib"
if defined BUILD_PREFIX (
  if exist "%BUILD_PREFIX%\Library\bin\lib.exe" set "AR=%BUILD_PREFIX%\Library\bin\lib.exe"
)

REM Cap'n Proto RPC: WIN32_LEAN_AND_MEAN fix is in 0002-win32-capnp-lean-mean.patch
REM (OmniPotentRPC/rgpot#61). Fortran pots enabled with ar=lib as above.
REM MESON_ARGS already sets buildtype/prefix/libdir.
meson setup builddir %MESON_ARGS% --native-file="%RECIPE_DIR%\win-flang-msvc.ini" -Dwith_rpc=true -Dwith_fortran_pots=enabled -Dwith_eigen=true -Dpure_lib=false -Dwith_cache=false -Dwith_tests=false -Dwith_examples=false
if errorlevel 1 exit 1

meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

meson install -C builddir
if errorlevel 1 exit 1
