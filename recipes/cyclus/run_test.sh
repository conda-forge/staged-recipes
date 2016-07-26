#!/bin/sh
cd $SRC_DIR/tests
test -f ${PREFIX}/bin/cyclus
test -f ${PREFIX}/bin/cycpp.py
#test -f ${PREFIX}/lib/libcyclus{{ libext }}
#test -f ${PREFIX}/lib/cyclus/libagents{{ libext }}
#test -f ${PREFIX}/lib/cyclus/libbaseagentunittests{{ libext }}
#test -f ${PREFIX}/lib/cyclus/libgtest{{ libext }}
#test -f ${PREFIX}/lib/cyclus/tests/libTestAgent{{ libext }}
#test -f ${PREFIX}/lib/cyclus/tests/libTestFacility{{ libext }}
#test -f ${PREFIX}/lib/cyclus/tests/libTestInst{{ libext }}
#test -f ${PREFIX}/lib/cyclus/tests/libTestRegion{{ libext }}
test -f ${PREFIX}/share/cyclus/cyclus_default_unit_test_driver.cc
test -f ${PREFIX}/share/cyclus/cyclus-flat.rng.in
test -f ${PREFIX}/share/cyclus/cyclus_nuc_data.h5
test -f ${PREFIX}/share/cyclus/cyclus.rng.in
test -f ${PREFIX}/share/cyclus/dbtypes.json
#- export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"  # [not osx]
#- export DYLD_LIBRARY_PATH="${PREFIX}/lib:${DYLD_LIBRARY_PATH}"  # [osx]
#- export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"  # [osx]
#export CYCLUS_PATH="$CYCLUS_PATH:$PREFIX/lib/cyclus"
export CYCLUS_PATH="$PREFIX/lib/cyclus"
#if [ -z "$CYCLUS_NUC_DATA" ]; then
#    export CYCLUS_NUC_DATA="$PREFIX/share/cyclus/cyclus_nuc_data.h5"
#fi
#if [ -z "$CYCLUS_RNG_SCHEMA" ]; then
#  export CYCLUS_RNG_SCHEMA="$PREFIX/share/cyclus/cyclus.rng.in"
#fi
${PREFIX}/bin/cyclus --version
${PREFIX}/bin/cyclus --path
${PREFIX}/bin/cyclus --include
${PREFIX}/bin/cyclus --install-path
${PREFIX}/bin/cyclus --cmake-module-path
${PREFIX}/bin/cyclus --build-path
${PREFIX}/bin/cyclus --rng-schema
${PREFIX}/bin/cyclus --nuc-data
export LD_LIBRARY_PATH="${PREFIX}/lib/cyclus:${LD_LIBRARY_PATH}"  # [not osx]
nosetests cycpp_tests.py
nosetests test_include_recipe.py  test_lotka_volterra.py
nosetests test_null_sink.py  test_source_to_sink.py
nosetests test_trivial_cycle.py test_inventories.py
nosetests test_minimal_cycle.py
${PREFIX}/bin/cyclus --version
${PREFIX}/bin/cyclus --path
${PREFIX}/bin/cyclus --include
${PREFIX}/bin/cyclus --install-path
${PREFIX}/bin/cyclus --cmake-module-path
${PREFIX}/bin/cyclus --build-path
${PREFIX}/bin/cyclus --rng-schema
${PREFIX}/bin/cyclus --nuc-data
${PREFIX}/bin/cyclus_unit_tests
