xcopy %CONDA_PREFIX%\\data data\\* /E /D
pushd tests
  python regressiontest_UK_100th.py
popd
