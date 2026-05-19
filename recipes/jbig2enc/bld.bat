@echo on
setlocal enabledelayedexpansion

:: Créer un dossier de build
mkdir build
cd build

:: Configuration avec CMake
cmake -G "Ninja" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      ..

:: Compilation et installation
cmake --build . --target install
