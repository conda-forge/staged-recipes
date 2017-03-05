#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-O2 -g -I$PREFIX/include $CFLAGS"

./configure   --disable-popcnt --disable-clz
make

check_output=`make checks`
echo "$check_output"

if [[ "$check_output" != *"PASSED ALL TESTS"* ]]; then
  exit
fi

for program in addedgeg amtog biplabg catg complg converseg copyg countg cubhamg deledgeg delptg directg dreadnaut dretodot dretog \
  genbg genbgL geng genquarticg genrang genspecialg gentourng gentreeg hamheuristic labelg linegraphg listg multig newedgeg \
  pickg planarg ranlabg shortg showg subdivideg twohamg vcolg watercluster2 NRswitchg;
do
  cp -p $program "$PREFIX"/bin/$program
done

