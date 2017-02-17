cmake -G"NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_PREFIX%\include" ^
      "%SRC_DIR%"
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
set LIB=%LIBRARY_LIB%;%LIB%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
