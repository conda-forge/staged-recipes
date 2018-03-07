
echo "CC is: $CC"
echo "CXX is: $CXX"
echo "Unsetting"
unset CC
unset CXX
echo "Clang env is:"
env | grep clang

python -m pip install --no-deps --ignore-installed .


