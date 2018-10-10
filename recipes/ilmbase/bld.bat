cmake -G "Ninja" ^ 
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_FIND_ROOT_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release

ninja
ninja install
