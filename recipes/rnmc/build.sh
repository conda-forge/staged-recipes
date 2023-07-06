mkdir -p build

flags="-fno-rtti -fno-exceptions -std=c++17 -Wall -Wextra -g $(gsl-config --cflags) $(gsl-config --libs) -lsqlite3 -lpthread"

echo "building test_core"
$CXX $flags ./core/test.cpp -o ./build/test_core
echo "building GMC"
$CXX $flags ./GMC/GMC.cpp -o ./build/GMC
echo "building NPMC"
$CXX $flags ./NPMC/NPMC.cpp -o ./build/NPMC
