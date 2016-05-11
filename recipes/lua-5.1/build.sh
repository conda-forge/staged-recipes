if [ `uname` == Darwin ]; then
	make macosx INSTALL_TOP=$PREFIX
fi
if [ `uname` == Linux ]; then
	make linux INSTALL_TOP=$PREFIX MYCFLAGS="-I$PREFIX/include -L$PREFIX/lib -DLUA_USE_LINUX -DLUA_USER_DEFAULT_PATH='\"$PREFIX/\"'" MYLDFLAGS="-L$PREFIX/lib -Wl,-rpath=$PREFIX/lib" #  "
fi
make install INSTALL_TOP=$PREFIX


