#!/bin/bash
${PERL} Makefile.PL INSTALLDIRS=site
make
make install
