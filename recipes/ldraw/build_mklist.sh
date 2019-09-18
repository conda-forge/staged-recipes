set -e
unzip -d mklist -o mklist1_6.zip

if [ $(uname) == Darwin ]; then
    INPLACE_SED="sed -i \"\" -e"
else
    INPLACE_SED="sed -i"
fi

$INPLACE_SED 's/CC=gcc/CC?=gcc/g' mklist/makefile
$INPLACE_SED 's/CFLAGS=/CFLAGS?=/g' mklist/makefile
$INPLACE_SED 's/_MAX_PATH/MAX_PATH/g' mklist/mklist.c
$INPLACE_SED 's/return(strlen(shortpath);/return(strlen(shortpath));/g' mklist/mklist.c
$INPLACE_SED 's/#include "string.h"/#include "string.h"\n#include "libgen.h"/g' mklist/mklist.c

cd mklist
mv include/* .

make
mkdir ${PREFIX}/bin
mv mklist ${PREFIX}/bin/
