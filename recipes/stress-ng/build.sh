

mkdir build

# ## Attempt BSD build
# CC=gcc make clean
# CC=gcc make install

# ## Attempt static build

make clean
BUILD_PREFIX=build STATIC=1 make

# ## Build with pedantic
# make clean
# PEDANTIC=1 make --prefix=build
