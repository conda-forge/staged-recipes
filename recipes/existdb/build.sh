mkdir -p "${PREFIX}/share/existdb"
mkdir -p "${PREFIX}/share/existdb/var/webapp/WEB-INF/data"

echo "INSTALL_PATH=${PREFIX}/share/existdb
dataDir=${PREFIX}/share/existdb/var/webapp/WEB-INF/data
MAX_MEMORY=1024
cacheSize=128
adminPasswd=admin" > "${RECIPE_DIR}/options.txt"

# Where are the existDB.jar file and install scripts
EXIST_SRC=$SRC_DIR

# Initialize the database
EXIST_HOME="${PREFIX}/share/existdb"

# Install the database
java -jar "${SRC_DIR}/existdb.jar" -console -options "${RECIPE_DIR}/options.txt"

cd $EXIST_HOME
java -jar start.jar jetty> /dev/null&
