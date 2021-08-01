cd $SRC_DIR
scons -c
scons
scons check
scons install prefix=$PREFIX
