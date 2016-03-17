set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

rmdir lib\cartopy\tests\mpl\baseline_images /s /q

%PYTHON% setup.py install
