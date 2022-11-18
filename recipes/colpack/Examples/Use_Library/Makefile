# make file for using installed library
# author xin cheng
# usage: chage the following two variable accordingly
COLPACK_INSTALL_PATH = ../../libs/libColPack.so
COLPACK_ROOT = ../..

SRC = $(wildcard *.cpp)
OBJ = $(SRC:%.cpp=%.o)
EXE = ColPack

# compiler
COMPILE = g++      # gnu

# compile flags
CCFLAGS = -Wall -fopenmp -O3 -std=c++11

# link flags
LDFLAGS = -Wall -fopenmp -O3 -std=c++11 -ldl ${COLPACK_INSTALL_PATH}

INCLUDES = -I./
INCLUDES+= -I${COLPACK_ROOT}/INC
INCLUDES+= -I${COLPACK_ROOT}/SRC/GeneralGraphColoring
INCLUDES+= -I${COLPACK_ROOT}/SRC/BipartiteGraphBicoloring
INCLUDES+= -I${COLPACK_ROOT}/SRC/BipartiteGraphPartialColoring
INCLUDES+= -I${COLPACK_ROOT}/SRC/Utilities


all: $(EXE)

%.o : %.cpp
	$(COMPILE) $(INCLUDES) $(CCFLAGS) -c $< -o $@

$(EXE): $(OBJ)
	$(COMPILE) $^ $(INCLUDES) $(LDFLAGS)  -o $@

clean:
	rm -f $(OBJ) $(EXE)

