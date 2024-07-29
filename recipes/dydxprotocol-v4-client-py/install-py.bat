@echo off

pushd v4-clients-py-v2
  %PYTHON% -m pip install . ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    --prefix "%PREFIX%"
  if errorlevel 1 exit 1
popd
