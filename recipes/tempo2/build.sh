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
etcdir=$PREFIX/etc/conda
mkdir -p $etcdir/activate.d
echo "if ( ! ($?TEMPO2) ) then; echo \"\";" > $etcdir/activate.d/tempo2-env.csh
echo "else setenv OLD_TEMPO2 $TEMPO2;" >> $etcdir/activate.d/tempo2-env.csh
echo "endif" >> $etcdir/activate.d/tempo2-env.csh
echo "setenv TEMPO2 $TEMPO2" > $etcdir/activate.d/tempo2-env.csh

echo "if [ ! -z $TEMPO2 ]; then export OLD_TEMPO2=$TEMPO2; fi" > $etcdir/activate.d/tempo2-env.sh
echo "export TEMPO2=$TEMPO2" >> $etcdir/activate.d/tempo2-env.sh

mkdir -p $etcdir/deactivate.d
echo "unsetenv TEMPO2" > $etcdir/deactivate.d/tempo2-env.csh
echo "if ( ! ($?OLD_TEMPO2) ) then; echo \"\";" > $etcdir/deactivate.d/tempo2-env.csh
echo "else setenv TEMPO2 $OLD_TEMPO2; unsetend OLD_TEMPO2;" >> $etcdir/deactivate.d/tempo2-env.csh
echo "endif" >> $etcdir/deactivate.d/tempo2-env.csh

echo "unset TEMPO2" > $etcdir/deactivate.d/tempo2-env.sh
echo "if [ ! -z $OLD_TEMPO2 ]; then export TEMPO2=$OLD_TEMPO2; unset OLD_TEMPO2;
 fi" >> $etcdir/deactivate.d/tempo2-env.sh
