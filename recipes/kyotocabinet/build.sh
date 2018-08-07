#!/bin/bash

PATCH_FILE=ksdbext.patch

touch $PATCH_FILE

echo "--- kyotocabinet-1.2.76/kcdbext.h	2016-05-25 11:32:53.591866016 +0200" >> $PATCH_FILE
echo "+++ kyotocabinet-1.2.76/kcdbext.h	2012-05-24 18:27:59.000000000 +0200" >> $PATCH_FILE
echo "@@ -1278,7 +1278,7 @@" >> $PATCH_FILE
echo "     if (omode_ == 0) {" >> $PATCH_FILE
echo "       set_error(_KCCODELINE_, BasicDB::Error::INVALID, "not opened");" >> $PATCH_FILE
echo "       *sp = 0;" >> $PATCH_FILE
echo "-      return false;" >> $PATCH_FILE
echo "+      return nullptr;" >> $PATCH_FILE
echo "     }" >> $PATCH_FILE
echo "     if (!cache_) return db_.get(kbuf, ksiz, sp);" >> $PATCH_FILE
echo "     size_t dvsiz = 0;" >> $PATCH_FILE

patch < $PATCH_FILE

set -e

./configure --prefix=$PREFIX \
	    --with-zlib=$PREFIX \
	    --with-bzip=$PREFIX

make
make check &> make_check.log || { cat make_check.log; exit 1; }
make install
