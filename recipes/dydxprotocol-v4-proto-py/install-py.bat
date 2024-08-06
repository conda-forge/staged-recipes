@echo off

pushd v4-proto-py
  %PYTHON% -m pip install . ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    --prefix "%PREFIX%"
  if errorlevel 1 exit 1
popd
