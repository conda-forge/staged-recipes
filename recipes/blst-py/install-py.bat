@echo off

pushd %SRC_DIR%\bindings\python
  %PYTHON% -m pip install . ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    -vvv ^
    --prefix "%PREFIX%"
  if errorlevel 1 exit 1

  dir %PREFIX%\Lib\site-packages
  dir %PREFIX%\Lib\site-packages\blst*
  %PYTHON% %RECIPE_DIR%\helpers\extract_test_run.me.py > %SRC_DIR%\test_blst.py
popd
