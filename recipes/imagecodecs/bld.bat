set INCLUDE=%LIBRARY_INC%\jxrlib;%LIBRARY_INC%\openjpeg-2.3;%LIBRARY_INC%\libpng16;%LIBRARY_INC%\webp;%LIBRARY_INC%\lzma;%INCLUDE%
set JPEG8_INCLUDE=%LIBRARY_INC%\jpeg8
set JPEG12_INCLUDE=%LIBRARY_INC%\jpeg12

rem it appears to be impossible to alter the command line of the Python extension compile
rem call in such a manner, that the standard include dir is NOT the first look-up path
rem as such, we move away the normal jpeg 8 headers, as elsewise we could never 
rem let the compiler use the jpeg 12 ones ...

mkdir "%JPEG8_INCLUDE%"

move "%LIBRARY_INC%\jconfig.h" "%JPEG8_INCLUDE%"
move "%LIBRARY_INC%\jmorecfg.h" "%JPEG8_INCLUDE%"
move "%LIBRARY_INC%\jerror.h" "%JPEG8_INCLUDE%"
move "%LIBRARY_INC%\jpeglib.h" "%JPEG8_INCLUDE%"

copy setup_modified.py setup.py

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

move "%JPEG8_INCLUDE%\jconfig.h" "%LIBRARY_INC%"
move "%JPEG8_INCLUDE%\jmorecfg.h" "%LIBRARY_INC%"
move "%JPEG8_INCLUDE%\jerror.h" "%LIBRARY_INC%"
move "%JPEG8_INCLUDE%\jpeglib.h" "%LIBRARY_INC%"

rmdir "%JPEG8_INCLUDE%"
