# (1) Replace "g++" by $(CXX) in the Makefile
sed -i 's/CXX      \:\= g++/# CXX      \:\= g++/g' ./Makefile
# (2) Rename the app to Raven, not Raven.exe in the Makefile
sed -i 's/appname \:\= Raven\.exe/appname \:\= raven/g' Makefile

make

cp ./raven $PREFIX/bin/raven
