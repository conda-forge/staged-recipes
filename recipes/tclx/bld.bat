call "%VS140COMNTOOLS%..\VC\bin\vcvars32.bat"
cd win
nmake -f makefile.vc
nmake -f makefile.vc install
