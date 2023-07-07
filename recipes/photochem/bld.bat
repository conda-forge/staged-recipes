setlocal EnableDelayedExpansion

cd %SRC_DIR%

set "CMAKE_GENERATOR=NMake Makefiles"

@echo off

echo "ls"
ls
IF "-d" "photochem-%PKG_VERSION%_withdata" (
  echo "mv photochem-%PKG_VERSION%_withdata/* ."
  mv "photochem-%PKG_VERSION%_withdata/*" "."
)
echo "ls"
ls

%PYTHON% -m pip install . -vv