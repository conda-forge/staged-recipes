# makefile for non-installed user
# author: xin cheng
# usage: change the following variable COLPACK_ROOT accordingly
#        delete OMP_FLAG=-fopenmp in MAC OS system
COLPACK_ROOT = ../..
COLPACK_SRC = $(wildcard ${COLPACK_ROOT}/src/GeneralGraphColoring/*.cpp)
COLPACK_SRC+= $(wildcard ${COLPACK_ROOT}/src/Utilities/*.cpp)
COLPACK_SRC+= $(wildcard ${COLPACK_ROOT}/src/BipartiteGraphBicoloring/*.cpp)
COLPACK_SRC+= $(wildcard ${COLPACK_ROOT}/src/BipartiteGraphPartialColoring/*.cpp)
COLPACK_SRC+= $(wildcard ${COLPACK_ROOT}/src/SMPGC/*.cpp)
COLPACK_SRC+= $(wildcard ${COLPACK_ROOT}/src/PartialD2SMPGC/*.cpp)

COLPACK_OBJ = $(COLPACK_SRC:%.cpp=%.o)
SRC = $(wildcard *.cpp)
OBJ = $(SRC:%.cpp=%.o) $(COLPACK_OBJ)
EXE = ColPack


# compiler
COMPILER = g++      # gnu
OMP_FLAG = -fopenmp 

#COMPILER = icc      # intel(R)
#OMP_FLAG = -openmp

# compile flags
CCFLAGS = -Wall -std=c++11 $(OMP_FLAG)  -Ofast -m64 # -D DEBUG_JP_PROFILE #-D PRINT_DETAILED_STATS_#-O3 
# link flags
LDFLAGS = -Wall -std=c++11 $(OMP_FLAG)  -Ofast -m64 # -D DEBUG_JP_PROFILE #-O3


INCLUDES = -I./
INCLUDES = -I${COLPACK_ROOT}/inc
INCLUDES+= -I${COLPACK_ROOT}/src/GeneralGraphColoring
INCLUDES+= -I${COLPACK_ROOT}/src/BipartiteGraphBicoloring
INCLUDES+= -I${COLPACK_ROOT}/src/BipartiteGraphPartialColoring
INCLUDES+= -I${COLPACK_ROOT}/src/Utilities
INCLUDES+= -I${COLPACK_ROOT}/src/Recovery
INCLUDES+= -I${COLPACK_ROOT}/src/SMPGC
INCLUDES+= -I${COLPACK_ROOT}/src/PartialD2SMPGC


all: $(EXE)

%.o : %.cpp
	$(COMPILER) $(INCLUDES) $(CCFLAGS) -c $< -o $@

$(EXE): $(OBJ)
	$(COMPILER) $^ $(INCLUDES) $(LDFLAGS)  -o $@

clean:
	rm -f $(OBJ) $(EXE)

