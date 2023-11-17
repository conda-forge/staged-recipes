@echo on

if [%PKG_NAME%] == [mlflow-skinny] (
  set MLFLOW_SKINNY=1
  # https://github.com/mlflow/mlflow/pull/4134
  copy %RECIPE_DIR%/README_SKINNY.rst %SRC_DIR%
)

%PREFIX%/python.exe -m pip install . --no-deps --ignore-installed -vv

if [%PKG_NAME%] == [mlflow] (
  bash -c 'rm ${PREFIX//\\\\//}/Lib/site-packages/mlflow/server/js/build/static/css/*.css.map'
  bash -c 'rm ${PREFIX//\\\\//}/Lib/site-packages/mlflow/server/js/build/static/js/*.js.map'
)
