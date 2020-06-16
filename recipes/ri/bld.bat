mv "%RECIPE_DIR%\sys" "%SRC_DIR%\sys" 
sed -i '66s/.*/#include \"sys\/time.h\"/' include\timer.h

make -B

mkdir "%PREFIX%/bin"
cp ri36 "%PREFIX%\bin"
chmod +x "%PREFIX%\bin\ri36"


