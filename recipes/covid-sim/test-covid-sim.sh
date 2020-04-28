#!/usr/bin/env bash

CovidSim 2>&1 | rg 'Syntax:'
ln -s ${CONDA_PREFIX}/data data

#
# While this does work, I would rather depend
# upon coreutils
#
# if [[ $(uname) == Darwin ]]; then
#   echo "#!/usr/bin/env bash"> ./sha256sum
#   echo "shasum -a256 \"\$@\"">> ./sha256sum
#   chmod +x ./sha256sum
#   echo "#!/usr/bin/env bash"> ./sha512sum
#   echo "shasum -a512 \"\$@\"">> ./sha512sum
#   chmod +x ./sha512sum
#   export "PATH=$PWD:$PATH"
# fi

pushd tests
  python regressiontest_UK_100th.py
  if [[ $? != 0 ]]; then
    echo "ERROR :: covid-sim testsuite failed"
    exit 1
  fi
popd

exit 0
