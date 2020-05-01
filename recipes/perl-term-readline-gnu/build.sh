#!/bin/bash
perl Makefile.PL INSTALLDIRS=site --prefix=$PREFIX
make -j${CPU_COUNT}
make install
