sed -i 's/gnu/msvc/' changeforest-r/src/Makevars.win
sed -i '1s/^/export CXX_STD=CXX11\n/' Makevars.win
sed -i '1s/^/export PKG_CXXFLAGS=$(CXX_VISIBILITY)\n/' Makevars.win
"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1