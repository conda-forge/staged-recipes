
echo "CC is: $CC"
echo "CXX is: $CXX"
echo "Unsetting"
unset CC
unset CXX

echo "/usr/bin/cc is: $(readlink /usr/bin/cc)"

echo "Tryna run cc"
cc --version

python -m pip install --no-deps --ignore-installed .


