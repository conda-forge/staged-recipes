mkdir -p "${PREFIX}/share/existdb"
mkdir -p "${PREFIX}/share/existdb/var/webapp/WEB-INF/data"

echo "INSTALL_PATH=${PREFIX}/share/existdb
dataDir=${PREFIX}/share/existdb/var/webapp/WEB-INF/data
MAX_MEMORY=1024
cacheSize=128
adminPasswd=admin" > "${RECIPE_DIR}/options.txt"

# Install the database
java -jar "${SRC_DIR}/existdb.jar" -console -options "${RECIPE_DIR}/options.txt"
