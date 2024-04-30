@echo off
%PYTHON% -m pip install quil-cli ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all: ^
  --no-index ^
  --find-links=%SRC_DIR%/wheels/ ^
  --prefix %PREFIX% ^
  -vv
