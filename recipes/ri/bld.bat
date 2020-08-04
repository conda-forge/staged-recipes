mv "%RECIPE_DIR%\sys" "%SRC_DIR%\sys"

make -B

mkdir "%PREFIX%/bin"
cp ri36 "%PREFIX%\bin"
chmod +x "%PREFIX%\bin\ri36"
