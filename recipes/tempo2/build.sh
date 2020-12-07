#! /bin/bash

./bootstrap
#export CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-O2//' | perl -pe 's/-std=.+ /-std=c++98 /')
#echo "CXXFLAGS $CXXFLAGS"

export TEMPO2=$PREFIX/share/tempo2
./configure --prefix=$PREFIX --disable-local --disable-psrhome PGPLOT_DIR=$PREFIX/include/pgplot
make -j${CPU_COUNT}
make install
make -j${CPU_COUNT} plugins
make plugins-install

# Copy runtime stuff
for dir in atmosphere ephemeris example_data observatory plugin_data solarWindModel clock earth
do
    cp -a T2runtime/$dir $TEMPO2/
done

# This foo will make conda automatically define a TEMPO2 env variable
# when the environment is activated.

ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/tempo2-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/tempo2-deactivate.sh
cp ${RECIPE_DIR}/scripts/activate.csh ${ACTIVATE_DIR}/tempo2-activate.csh
cp ${RECIPE_DIR}/scripts/deactivate.csh ${DEACTIVATE_DIR}/tempo2-deactivate.csh
cp ${RECIPE_DIR}/scripts/activate.fish ${ACTIVATE_DIR}/tempo2-activate.fish
cp ${RECIPE_DIR}/scripts/deactivate.fish ${DEACTIVATE_DIR}/tempo2-deactivate.fish
