#!/bin/bash
perl Makefile.PL INSTALLDIRS=site
make -j${CPU_COUNT}
make install
