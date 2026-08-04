@echo on
setlocal EnableDelayedExpansion

REM Fortran pots still off on Windows (flang archive vs MSVC link).
REM Cap'n Proto RPC is ON: WIN32_LEAN_AND_MEAN is fixed upstream
REM (OmniPotentRPC/rgpot#61 / 0002-win32-capnp-lean-mean.patch).
REM MESON_ARGS already sets buildtype/prefix/libdir.
meson setup builddir %MESON_ARGS% -Dwith_rpc=true -Dwith_fortran_pots=disabled -Dwith_eigen=true -Dpure_lib=false -Dwith_cache=false -Dwith_tests=false -Dwith_examples=false
if errorlevel 1 exit 1

meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

meson install -C builddir
if errorlevel 1 exit 1
