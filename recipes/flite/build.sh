set -exou

./configure --with-vox=cmu_us_kal16 --enable-shared --prefix="$(pwd)/build"

make

make install
