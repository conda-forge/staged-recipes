#! /bin/sh

make install-libs
rm "${PREFIX}/lib/lib"{com_err,e2p,ext2fs,ss}.a
