cd asio\src

nmake -f Makefile.msc STANDALONE=1
if errorlevel 1 exit 1

xcopy %SRC_DIR%\asio\include\asio.hpp %LIBRARY_INC%\ /i
if errorlevel 1 exit 1

xcopy %SRC_DIR%\asio\include\asio %LIBRARY_INC%\asio /s /i /y
if errorlevel 1 exit 1
