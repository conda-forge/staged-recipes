set INCLUDE=%LIBRARY_INC%\jxrlib;%LIBRARY_INC%\openjpeg-2.3;%LIBRARY_INC%\libpng16;%LIBRARY_INC%\webp;%LIBRARY_INC%\lzma;%INCLUDE%

copy setup_modified.py setup.py

set
dir /s /b %CONDA_PREFIX%

dir /s /b %LIBRARY_PREFIX%

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
