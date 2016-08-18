#!/bin/sh
# setup env for tests
cd "${SRC_DIR}/tests"
export PATH="${PREFIX}/bin:${PATH}"
export CYCLUS_PATH="${PREFIX}/lib/cyclus"
if [ -z "$CYCLUS_NUC_DATA" ]; then
  export CYCLUS_NUC_DATA="${PREFIX}/share/cyclus/cyclus_nuc_data.h5"
fi

UNAME="$(uname)"
if [ "${UNAME}" == "Darwin" ]; then
  export DYLD_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${DYLD_LIBRARY_PATH}"

  #echo "Not changing library paths"
  #export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib/cyclus:${DYLD_FALLBACK_LIBRARY_PATH}"
  export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
  #export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib/cyclus:${DYLD_FALLBACK_LIBRARY_PATH}"
else
  export LD_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${LD_LIBRARY_PATH}"
fi

# check that the files exist
test -f ${PREFIX}/bin/cyclus
test -f ${PREFIX}/bin/cycpp.py
test -f ${PREFIX}/share/cyclus/cyclus_default_unit_test_driver.cc
test -f ${PREFIX}/share/cyclus/cyclus-flat.rng.in
test -f ${PREFIX}/share/cyclus/cyclus_nuc_data.h5
test -f ${PREFIX}/share/cyclus/cyclus.rng.in
test -f ${PREFIX}/share/cyclus/dbtypes.json

# output cyclus info
which cyclus
if [ "${UNAME}" == "Darwin" ]; then
  otool -l $(which cyclus)
  otool -L $(which cyclus)
fi
${PREFIX}/bin/cyclus --version
${PREFIX}/bin/cyclus --path
${PREFIX}/bin/cyclus --include
${PREFIX}/bin/cyclus --install-path
${PREFIX}/bin/cyclus --cmake-module-path
${PREFIX}/bin/cyclus --build-path
${PREFIX}/bin/cyclus --rng-schema
${PREFIX}/bin/cyclus --nuc-data
${PREFIX}/bin/cyclus -l :agents
${PREFIX}/bin/cyclus -a

# run unit tests
${PREFIX}/bin/cyclus_unit_tests

# run integration tests
nosetests cycpp_tests.py
nosetests test_include_recipe.py  test_lotka_volterra.py
nosetests test_null_sink.py  test_source_to_sink.py
nosetests test_trivial_cycle.py test_inventories.py
nosetests test_minimal_cycle.py
