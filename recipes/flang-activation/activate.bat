set "CONDA_BACKUP_FC=%FC%"
set "CONDA_BACKUP_FFLAGS=%FFLAGS%"
set "CONDA_BACKUP_LD=%LD%"
set "CONDA_BACKUP_LDFLAGS=%LDFLAGS%"

:: flang 19 still uses "temporary" name
set "FC=flang-new"
set "LD=lld-link.exe"

:: following https://github.com/conda-forge/clang-win-activation-feedstock/blob/main/recipe/activate-clang_win-64.bat
set "FFLAGS=-D_CRT_SECURE_NO_WARNINGS -fms-runtime-lib=dll -fuse-ld=lld -I%LIBRARY_INC%"
set "LDFLAGS=%LDFLAGS% -Wl,-defaultlib:%CONDA_PREFIX:\=/%/lib/clang/@MAJOR_VER@/lib/windows/clang_rt.builtins-x86_64.lib"
