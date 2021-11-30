echo "export CXX_STD=CXX11" > tempfile
IF %ERRORLEVEL% NEQ 0 exit 1
echo "export PKG_CXXFLAGS=\$(CXX_VISIBILITY)" >> tempfile
IF %ERRORLEVEL% NEQ 0 exit 1
echo "PATH=\"\$(subst C:\,/c/,\$(RTOOLS40_HOME))/mingw\$(WIN)/bin:\$(PATH)\"" >> tempfile
IF %ERRORLEVEL% NEQ 0 exit 1
cat changeforest-r/src/Makevars.win >> tempfile
IF %ERRORLEVEL% NEQ 0 exit 1
mv tempfile changeforest-r/src/Makevars.win
IF %ERRORLEVEL% NEQ 0 exit 1

sed -i 's/gnu/msvc/' changeforest-r/src/Makevars.win
IF %ERRORLEVEL% NEQ 0 exit 1

"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1