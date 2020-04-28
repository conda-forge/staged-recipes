#!/usr/bin/env bash
CovidSim 2>&1 | rg 'Syntax:'
ln -s ${CONDA_PREFIX}/data data
if [[ $(uname) == Darwin ]]; then
  echo "#!/usr/bin/env bash"> ./sha256sum
  echo "shasum -n 256 \"$@\"">> ./sha256sum
  chmod +x ./sha256sum
  export "PATH=$PWD:$PATH"
fi
pushd tests
  python regressiontest_UK_100th.py
  if [[ $? != 0 ]]; then
    echo "ERROR :: covid-sim testsuite failed"
    exit 1
  fi
popd
exit 0

