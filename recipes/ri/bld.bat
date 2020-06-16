

cp -R "%RECIPE_DIR%/sys/*" "include"

ls -l include

sed -i.bak 's/<sys\/time.h>/"time.h"/g' include/timer.h

ls

mkdir -p "%PREFIX%/bin"
make -B

ls

cp ri36 "%PREFIX%/bin"
chmod +x "%PREFIX%/bin/ri36"


