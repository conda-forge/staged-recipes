REM set INCLUDE=%LIBRARY_INC%\jxrlib;%INCLUDE%
set INCLUDE=%LIBRARY_INC%\openjpeg-2.3;%INCLUDE%
set INCLUDE=%LIBRARY_INC%\libpng16;%INCLUDE%
set INCLUDE=%LIBRARY_INC%\webp;%INCLUDE%
set INCLUDE=%LIBRARY_INC%\lzma;%INCLUDE%

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

