if [ `uname` == Darwin ]; then
	make macosx INSTALL_TOP=$PREFIX
	make macosx test
elif [ `uname` == Linux ]; then
	make linux INSTALL_TOP=$PREFIX MYCFLAGS="-I$PREFIX/include -L$PREFIX/lib -DLUA_USE_LINUX -DLUA_USER_DEFAULT_PATH='\"$PREFIX/\"'" MYLDFLAGS="-L$PREFIX/lib -Wl,-rpath=$PREFIX/lib"
	make linux test
fi
make install INSTALL_TOP=$PREFIX