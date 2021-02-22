

mkdir build

# ## Attempt BSD build
# CC=gcc make clean
# CC=gcc make install

# ## Attempt static build
make clean
STATIC=1 make --prefix=build

# ## Build with pedantic
# make clean
# PEDANTIC=1 make --prefix=build
