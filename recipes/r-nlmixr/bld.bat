%SRC_DIR%>set "CXX_STD=CXX14"
%SRC_DIR%>set "CXX14STD=-std=c++1y"

"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
