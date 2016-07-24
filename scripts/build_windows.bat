:: Workaround for https://github.com/conda/conda-build/issues/636
set "PYTHONIOENCODING=UTF-8"

:: SDK v7.0 MSVC Express 2008's SetEnv.cmd script will fail if the
:: /E:ON and /V:ON options are not enabled in the batch script interpreter
:: See: http://stackoverflow.com/a/13751649/163740
set "CMD_IN_ENV=call cmd /E:ON /V:ON /C obvci_appveyor_python_build_env.cmd"

:: Build all of the recipes.
%CMD_IN_ENV% conda-build-all recipes --matrix-conditions "numpy >=1.10" "%PY_CONDITION%"
