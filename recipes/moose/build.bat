@echo on
setlocal enabledelayedexpansion

REM Set LLVM/Clang path (conda-forge clang should be in PATH)
REM The conda-forge clang package should handle this automatically

REM Clean and configure build using Meson with Windows-specific options
meson setup --wipe _build ^
    --prefix=%PREFIX% ^
    --buildtype=release ^
    --vsenv ^
    -Duse_mpi=false ^
    -Duse_hdf5=true
if errorlevel 1 exit 1

REM Compile with verbose output
meson compile -vC _build
if errorlevel 1 exit 1

REM Install
meson install -C _build
if errorlevel 1 exit 1
