set INCLUDE=%LIBRARY_INC%\jxrlib;%LIBRARY_INC%\openjpeg-2.3;%LIBRARY_INC%\libpng16;%LIBRARY_INC%\webp;%LIBRARY_INC%\lzma;%INCLUDE%
set JPEG12_INCLUDE=%LIBRARY_INC%\jpeg12

copy setup_modified.py setup.py

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
