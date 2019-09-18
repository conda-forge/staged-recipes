cd ldraw

mkdir %LIBRARY_PREFIX%\share\ldraw
mkdir %LIBRARY_PREFIX%\share\ldraw\p
mkdir %LIBRARY_PREFIX%\share\ldraw\parts
mkdir %LIBRARY_PREFIX%\share\ldraw\models

xcopy p\* %LIBRARY_PREFIX%\share\ldraw\p\ /s /y
xcopy parts\* %LIBRARY_PREFIX%\share\ldraw\parts\ /s /y
xcopy models\* %LIBRARY_PREFIX%\share\ldraw\models\ /s /y
if errorlevel 1 exit 1
