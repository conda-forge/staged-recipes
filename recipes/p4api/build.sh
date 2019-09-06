echo 'using gcc-conda : 7.3 : ${CC} ;' >> user-config.jam

jam -sPRODUCTION=1 -sSSLINCDIR=$PREFIX/include --toolset=gcc-conda-7.3 -sSSLLIBDIR=$PREFIX/lib -sSMARTHEAP=0 -sC++=$CXX -sg++=$CXX -sCc=$CC -sCC=$CC p4api.tar
