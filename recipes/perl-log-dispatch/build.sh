#!/bin/bash
perl Makefile.PL INSTALLDIRS=site
make
make install
