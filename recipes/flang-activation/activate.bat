set "_OLD_FC=%FC%"
set "_OLD_FFLAGS=%FFLAGS%"
set "_OLD_LD=%LD%"
set "_OLD_LDFLAGS=%LDFLAGS%"

:: flang 19 still uses "temporary" name
set "FC=flang-new"
set "LD=lld-link.exe"

:: following https://github.com/conda-forge/clang-win-activation-feedstock/blob/main/recipe/activate-clang_win-64.bat
set "FFLAGS=-D_CRT_SECURE_NO_WARNINGS -fms-runtime-lib=dll -fuse-ld=lld -I%LIBRARY_INC%"
set "LDFLAGS=-Wl,-defaultlib:%CONDA_PREFIX:\=/%/lib/clang/@MAJOR_VER@/lib/windows/clang_rt.builtins-x86_64.lib"
