call "%VS140COMNTOOLS%..\VC\bin\vcvars32.bat"
cd win
nmake -f makefile.vc TCLDIR="%PREFIX%\Library\"
nmake -f makefile.vc install
