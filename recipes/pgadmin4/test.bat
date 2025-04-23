echo source D:/Miniforge/etc/profile.d/conda.sh       >  conda_test.sh
echo conda activate "${PREFIX}"                       >> conda_test.sh
echo conda activate --stack "${BUILD_PREFIX}"         >> conda_test.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_test.sh
type "%RECIPE_DIR%\test.sh"                           >> conda_test.sh

set PREFIX=%PREFIX:\=/%
set CONDA_PREFIX=%CONDA_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lce "./conda_test.sh"
if errorlevel 1 exit 1
