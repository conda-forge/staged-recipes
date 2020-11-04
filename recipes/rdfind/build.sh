# conflicts with '#include <version>'
rm -f ${SRC_DIR}/VERSION

./bootstrap.sh
./configure --prefix=$PREFIX
make -j${CPU_COUNT}

# Need a non coreutils binary for testing
sed -i.bak "s,which ls,which grep,g" testcases/symlinking_action.sh
sed -i.bak "s,which ls,which grep,g" testcases/hardlink_fails.sh

make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
