#!/bin/bash
set -e


as_run --test sslp114a
as_run --test mumps02a
as_run --test mumps01a
##as_run --test mfron01a # missing mfront exe
#as_run --test ssnl127a
#as_run --test umat001a
##as_run --test hplv101a # missing mfront exe
#as_run --test zzzz413a
#as_run --test comp003a
#as_run --test sdll123a # <FACTOR_82> in 15.2
#as_run --test ssls126e # MACR_ELAS_MULT DVP_0 in Ubuntu 20.04

#source $PREFIX/15.2/share/aster/profile.sh
#python -c "import code_aster"