@echo on
setlocal EnableDelayedExpansion

REM Windows: skip Cap'n Proto RPC frontends (MSVC + capnp headers hit
REM IPrintDialogServices / windows.h pollution). Classical pair pots still
REM build. Fortran pots remain off (flang archive vs MSVC link).
REM MESON_ARGS already sets buildtype/prefix/libdir.
meson setup builddir %MESON_ARGS% -Dwith_rpc=false -Dwith_fortran_pots=disabled -Dwith_eigen=true -Dpure_lib=false -Dwith_cache=false -Dwith_tests=false -Dwith_examples=false
if errorlevel 1 exit 1

meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

meson install -C builddir
if errorlevel 1 exit 1
