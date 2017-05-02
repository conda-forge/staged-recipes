export DOTMONETDBFILE="monetdb_config"

farm="$PWD/dbfarm"
db="demo"
port="56789"
user="monetdb"
password="monetdb"
table="names"

mdb="monetdb -p $port"
mdb_daemon="monetdbd"
mdb_client="mclient -p $port  -d $db"

# Create configuration file
cat << EOF > $DOTMONETDBFILE
user=$user
password=$password
EOF

# Create database farm
$mdb_daemon create $farm
$mdb_daemon set port=$port $farm
$mdb_daemon start $farm
$mdb_daemon get all $farm

# Create a `demo` database
$mdb create $db
$mdb start  $db
$mdb status

# Create table
echo "CREATE TABLE $table (id integer,name varchar(20));" | $mdb_client

# Add row to table
echo "INSERT INTO $table VALUES (0, 'Alice');" | $mdb_client
echo "INSERT INTO $table VALUES (1, 'Bob');" | $mdb_client

# Get values
echo "SELECT * FROM $table;" | $mdb_client

# Remove database, farm and config file
$mdb stop $db
$mdb destroy -f $db
$mdb_daemon stop $farm
rm -rf $farm $DOTMONETDBFILE
