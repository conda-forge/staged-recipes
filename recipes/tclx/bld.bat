call "%VS140COMNTOOLS%..\VC\bin\vcvars32.bat"
nmake -f win/makefile.vc TCLDIR=%PREFIX%/Library/
nmake -f win/makefile.vc install
