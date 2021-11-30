sed -i 's/gnu/msvc/' changeforest-r/src/Makevars.win
sed -i '1s/^/export CXX_STD=CXX11\n/' changeforest-r/src/Makevars.win
sed -i '1s/^/export PKG_CXXFLAGS=$(CXX_VISIBILITY)\n/' changeforest-r/src/Makevars.win
sed -i 's/cargo build/PATH="$(subst C:\,/c/,$(RTOOLS40_HOME))/mingw$(WIN)/bin:$(PATH)" cargo build/' changeforest-r/src/Makevars.win
"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1