set -ex

# Check for expected libraries ABI
test -f ${PREFIX}/lib/bigdft/libvol.so
test -f ${PREFIX}/lib/libatlab-1.so.0
test -f ${PREFIX}/lib/libbigdft-1.so.9
test -f ${PREFIX}/lib/libCheSS-1.so.2
test -f ${PREFIX}/lib/libfmalloc-1.so.9
test -f ${PREFIX}/lib/libfutile-1.so.9
test -f ${PREFIX}/lib/libPSolver-1.so.9

# Check for header
test -f ${PREFIX}/include/bigdft.h
test -f ${PREFIX}/include/futile/tree.h
test -f ${PREFIX}/include/atlab/box.h

# Setup the environment
source bigdftvars.sh

# Check a few of the useful tools
bigdft -h
bigdft-tool -h
bader -h

# Check that PyBigDFT is Working
python test.py
