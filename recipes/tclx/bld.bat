call "%VS140COMNTOOLS%..\VC\bin\vcvars32.bat"
cd win
echo %PREFIX%
nmake -f makefile.vc TCLDIR=%PREFIX%/Library/
nmake -f makefile.vc install
