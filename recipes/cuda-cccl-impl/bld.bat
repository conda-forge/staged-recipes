if not exist %PREFIX% mkdir %PREFIX%
mkdir %LIBRARY_LIB%\cmake
mkdir %LIBRARY_INC%

move thrust\thrust\cmake %LIBRARY_LIB%\cmake\thrust
move cub\cub\cmake %LIBRARY_LIB%\cmake\cub
move libcudacxx\lib\cmake\libcudacxx %LIBRARY_LIB%\cmake

move thrust\thrust %LIBRARY_INC%
move cub\cub %LIBRARY_INC%
move libcudacxx\include\cuda %LIBRARY_INC%
move libcudacxx\include\nv %LIBRARY_INC%
