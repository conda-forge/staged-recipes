
echo "CC is: $CC"
echo "CXX is: $CXX"
echo "Unsetting"
unset CC
unset CXX

echo "/usr/bin/cc is: $(readlink -f /usr/bin/cc)"

python -m pip install --no-deps --ignore-installed .


