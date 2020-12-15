echo "****************************"
echo "DEVEL LIBRARY INSTALL STARTED"
echo "****************************"

set -e

test -f cantera.conf

scons install

echo "****************************"
echo "DEVEL LIBRARY INSTALL COMPLETED SUCCESSFULLY"
echo "****************************"
